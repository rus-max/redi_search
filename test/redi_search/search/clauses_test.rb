# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    class ClausesTest < ActiveSupport::TestCase
      setup do
        @index = Index.new("user_idx", name: :text)
        @index.drop
        @index.create
      end

      teardown do
        @index.drop
      end

      test "slop clause" do
        query = RediSearch::Search.new(@index, "dr")

        assert_equal(
          "SEARCH user_idx `dr` SLOP 1", query.slop(1).to_redis
        )
      end

      test "#in_order clause" do
        query = RediSearch::Search.new(@index, "dr")

        assert_equal(
          "SEARCH user_idx `dr` INORDER", query.in_order.to_redis
        )
      end

      test "#language clause" do
        query = RediSearch::Search.new(@index, "dr")

        assert_equal(
          "SEARCH user_idx `dr` LANGUAGE danish",
          query.language("danish").to_redis
        )
      end

      test "#sort_by clause" do
        query = RediSearch::Search.new(@index, "dr")

        assert_equal(
          "SEARCH user_idx `dr` SORTBY first asc",
          query.sort_by(:first).to_redis
        )
      end

      test "#sort_by desc clause" do
        query = RediSearch::Search.new(@index, "dr")

        assert_equal(
          "SEARCH user_idx `dr` SORTBY first desc",
          query.sort_by(:first, order: :desc).to_redis
        )
      end

      test "#sort_by arg error with bad order" do
        query = RediSearch::Search.new(@index, "dr")

        assert_raise ArgumentError do
          query.sort_by(:first, order: :random)
        end
      end

      test "#limit clause defaults to 0 offset" do
        query = RediSearch::Search.new(@index, "dr")

        assert_equal(
          "SEARCH user_idx `dr` LIMIT 0 10",
          query.limit(10).to_redis
        )
      end

      test "#limit clause with custom offset" do
        query = RediSearch::Search.new(@index, "dr")

        assert_equal(
          "SEARCH user_idx `dr` LIMIT 5 10",
          query.limit(10, 5).to_redis
        )
      end
    end
  end
end