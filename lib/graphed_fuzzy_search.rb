#require "graphed_fuzzy_search/version"

module GraphedFuzzySearch
  def self.new(*args, **kwargs)
    Collection.new(*args, **kwargs)
  end

  DEFAULT_TOKEN_REGEX = /[^\p{Punct}\p{Space}]+/

  class Collection
    def initialize(objects, attributes: [:to_s], token_regex: DEFAULT_TOKEN_REGEX, normal_weight: 1, different_token_weight: 5)
      @objects = objects
      @attributes = attributes
      @token_regex = token_regex
      @normal_weight = normal_weight
      @different_token_weight = different_token_weight
      trees
    end

    def inspect
      "#<#{self.class.name}>"
    end

    attr_reader :objects, :attributes, :token_regex
    attr_reader :normal_weight, :different_token_weight

    def query(*args, **kwargs)
      query_raw(*args, **kwargs).map{ |(node, _)| node.item.object }
    end

    def query_raw(str, max_scan: str.size)
      str = str.downcase
      chars = str.chars
      i = 0
      needles = trees.map { |root| [root, 0] }
      while i < chars.size && i < max_scan && !needles.empty?
        char = chars[i]
        needles.map! { |(node, weight)| [node[char], weight] }
        needles.select!(&:first)
        needles.map! { |(conn, weight)| [conn.node, weight + conn.weight] }
        i += 1
      end
      needles.map! { |(conn, weight)|
        if conn.item.key.start_with?(str)
          weight *= 0.7
        end
        [conn, weight]
      }
      needles.sort_by(&:last)
    end

    def items
      @items ||= objects.map do |obj|
        attrs = attributes.flat_map do |k|
          [*obj.send(k)]
        end
        tokens = attrs.flat_map do |attr|
          attr.to_s.downcase.scan(token_regex)
        end
        tokens.push(*attrs)
        Item.new(obj, attrs[0], tokens)
      end
    end

    def trees
      @trees ||= items.map do |item|
        root = Node.new(nil, [], item)
        token_and_heads = item.tokens.map do |token|
          root.mine(normal_weight, token)
          [token, root[token[0]].node]
        end
        token_and_heads.each do |(_, ah)|
          token_and_heads.each do |(bt, _)|
            root.walk(bt.each_char) do |n|
              n.connect(different_token_weight, ah)
            end
          end
        end
        root
      end
    end
  end

  Item = Struct.new(:object, :key, :tokens)
  Connection = Struct.new(:weight, :node)

  Node = Struct.new(:str, :adjacents, :item) do
    def inspect
      "#<#{self.class.name} @item=#{item.inspect} @str=#{str.inspect} adjacents=#{adjacents.map(&:first).join}>"
    end
    def head
      str[0]
    end

    def length
      str.size
    end

    def [](k)
      self.adjacents ||= []
      _, adjacent = adjacents.find { |c, _| c == k }
      adjacent
    end

    def walk(enum)
      weight = 0
      enum.inject(self) do |r, i|
        c = r[i]
        raise unless c
        weight += c.weight
        yield c.node
        c.node
      end
      weight
    end

    def mine(weight, str)
      str.each_char.inject(self) do |r, i|
        r.connect(weight, Node.new(i, [], self.item))
      end
    end

    def connect(weight, node)
      return nil if node.__id__ == self.__id__
      self.adjacents ||= []
      connection = self[node.str]
      return connection.node if connection
      adjacents << [node.head, Connection.new(weight, node)]
      node
    end
  end
end
