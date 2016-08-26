module EchoCommon
  module Sequel

    # Integrates with Sequel and adds support for objects responding to #to_s to
    # being used directly in a SQL query.
    #
    # NOTE: Don't use this with MySql as you do need to escape more characters.
    #   See:
    #   * https://github.com/jeremyevans/sequel/commit/78f725956b9cad4eaf47da089b5385cb71c8f173
    #   * https://github.com/jeremyevans/sequel/blob/78f725956b9cad4eaf47da089b5385cb71c8f173/lib/sequel/dataset/sql.rb#L1092-L1095
    #
    # Example
    #
    #   class MyClass
    #     include EchoCommon::Sequel::SqlLiteral
    #
    #     def initialize(v)
    #       @v = v
    #     end
    #
    #     def to_s
    #       @v
    #     end
    #   end
    #
    #   my_object = MyClass.new "some-value"
    #   sequel_dataset.where(column: my_object)
    module SqlLiteral
      APOS = "'".freeze
      APOS_REG = /'/.freeze
      DOUBLE_APOS = "''".freeze

      # Used by Sequel when we use a UUID value in a where statement
      def sql_literal(sql)
        '' << APOS << to_s.gsub(APOS_REG, DOUBLE_APOS) << APOS
      end
    end
  end
end
