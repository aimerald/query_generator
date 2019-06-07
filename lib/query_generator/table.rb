module QueryGenerator
  class Table
    attr_reader :table, :query, :select_used, :where_used, :strict
    def initialize(table, strict: true)
      @table = table
      @query = ''
      @select_used = false
      @where_used = false
      @strict = strict
    end

    def select(*columns)
      raise SelectAlreadyUsed if select_used

      @query = "SELECT #{result_columns(columns)} FROM #{table}"
      @select_used = true
      self
    end

    def where(*conds)
      @query += if where_used
                  " AND #{expand_conds(conds)}"
                else
                  " WHERE #{expand_conds(conds)}"
                end
      @where_used = true
      self
    end

    def or(*conds)
      # NOTE: OR句はWHERE句のあとに使うので単独では使わせない
      raise WhereDoesNotUsed unless where_used

      @query += " OR #{expand_conds(conds, 'OR')}"
      self
    end

    def group_by(*columns)
      @query += " GROUP BY #{columns.join(',')}"
      self
    end

    def order_by(by, order_type = :ASC)
      raise NotIncludeType unless [:ASC, :DESC].include?(order_type.upcase)

      @query += " ORDER BY #{by} #{order_type.upcase}"
      self
    end

    def run
      raise StrictModeError if !where_used && strict
      # FIXME:　各DBへSQLを実行しその結果を取得する
    end

    def to_s
      raise StrictModeError if !where_used && strict

      puts query
    end

    def left_outer_join(join_table, base, to)
      "LEFT #{outer_join(join_table, base, to)}"
    end

    def right_outer_join(join_table, base, to)
      "RIGHT #{outer_join(join_table, base, to)}"
    end

    private

    def outer_join(join_table, base, to)
      "OUTER JOIN #{join_table} ON #{base} = #{to}"
    end

    def expand_conds(conds, join_cond = 'AND')
      conds.map do |s_exp|
        "#{car(s_exp)} #{parse_cond(cdr(s_exp))}"
      end.join(" #{join_cond} ")
    end

    def parse_cond(s_exp)
      case car(s_exp)
      when :is then "IS #{parse_type(car(cdr(s_exp)))}"
      when :eq then "= #{parse_type(car(cdr(s_exp)))}"
      when :not_eq then "!= #{parse_type(car(cdr(s_exp)))}"
      when :in then "IN #{parse_in(cdr(s_exp))}"
      when :like then "LIKE #{parse_type(car(cdr(s_exp)))}"
      when :between
        from_and_to = car(cdr(s_exp))
        from = car(from_and_to)
        to = car(cdr(from_and_to))
        "BETWEEN '#{parse_date_and_timestamp(from)}' AND '#{parse_date_and_timestamp(to)}'"
      end
    end

    def parse_date_and_timestamp(time)
      case time
      when Date then time.strftime('%Y-%m-%d')
      when Time then time.strftime('%Y-%m-%d %H:%M:%S')
      end
    end

    def parse_in(list)
      # NOTE: IN句には配列を渡す想定だが[]で出力されるため()に置換する
      list.flatten.to_s.sub('[', '(').sub(']', ')')
    end

    def parse_type(atom)
      case atom
      when NilClass then 'NULL'
      when Fixnum, Float, TrueClass, FalseClass then atom
      when String then "'#{atom}'"
      when Time, Date then "'#{parse_date_and_timestamp(atom)}'"
      end
    end

    def car(list)
      list.first
    end

    def cdr(list)
      list.drop(1)
    end

    def result_columns(selects)
      return '*' if selects == []

      selects.map do |select_with_conds|
        conds_with_as = cdr(select_with_conds)
        conds = conds_with_as.reject { |e| e.class == Hash }.sort.reverse
        as = conds_with_as.select { |e| e.class == Hash }[0][:as] rescue nil

        if as
          "#{parse_select(car(select_with_conds), conds)} AS #{as}"
        else
          parse_select(car(select_with_conds), conds)
        end
      end.join(', ')
    end

    def parse_select(select, conds)
      return select if conds == []

      cond = car(conds)
      parse_select("#{cond}(#{select})", cdr(conds))
    end
  end
end
