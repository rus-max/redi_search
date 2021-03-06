# frozen_string_literal: true

require "redi_search/lazily_load"

require "redi_search/search/clauses"
require "redi_search/search/term"
require "redi_search/search/result"

module RediSearch
  class Search
    extend Forwardable
    include LazilyLoad
    include Clauses

    attr_reader :term_clause, :used_clauses, :index, :clauses

    def_delegator :index, :model

    def initialize(index, term = nil, **term_options)
      @index = index
      @clauses = []
      @used_clauses = Set.new

      @term_clause = term &&
        And.new(self, term, nil, **term_options)
    end

    def results
      if model
        no_content unless loaded?

        model.where(id: to_a.map(&:document_id_without_index))
      else
        to_a
      end
    end

    def explain
      RediSearch.client.call!(
        "EXPLAINCLI", index.name, term_clause.to_s
      ).join(" ").strip
    end

    def dup
      self.class.new(index)
    end

    private

    attr_writer :index, :clauses

    def command
      ["SEARCH", index.name, term_clause.to_s, *clauses]
    end

    def parse_response(response)
      @documents = Result.new(self, response[0], response[1..-1])
    end

    def valid?
      !term_clause.to_s.empty?
    end
  end
end
