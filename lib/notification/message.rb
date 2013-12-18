module Notification
  class Message
    attr_accessor :id, :sender, :type, :text, :timestamp

    def initialize(args={})
      self.id = args[:id] || SecureRandom.hex

      # FIXME: currently it's allowed to set all attributes from args hash
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    # === Class methods ===
    class << self
      def namespace
        Redis::Namespace.new("notification::messages", :redis => REDIS)
      end

      def find(id)
        json = self.namespace.get(id)
        self.new(JSON.parse(json).deep_symbolize_keys) if json
      end

      def first
        self.all.first
      end

      def last
        self.all.last
      end

      def all
        self.namespace.keys.collect { |id| self.find(id) }.sort_by(&:timestamp)
      end

      def destroy_all()
        self.namespace.flushall
      end
    end

    # === Instance methods ===
    def save
      self.timestamp = Time.now.to_i
      self.class.namespace.set(self.id, self.to_json) == "OK"
    end

    def destroy
      self.class.namespace.del(self.id) == 1 ? true : false
    end

    def to_json
      Hash[self.instance_variables.map{|k, v| [k[1..-1].to_sym, self.send(k[1..-1])]}].to_json
    end
  end
end
