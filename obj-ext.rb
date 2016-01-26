class Object
  def try(method)
    send method if respond_to? method
  end
end


Object.class_eval do
  def self.attr_accessor(*vars)
    @attributes ||= []
    @attributes.concat vars
    super(*vars)
  end

  def self.attributes
    @attributes
  end

  def attributes
    self.class.attributes
  end

  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end
end

Hash.class_eval do
  def symbolize_keys
    transform_keys{ |key| key.to_sym rescue key }
  end

  def transform_keys
    return enum_for(:transform_keys) unless block_given?
    result = self.class.new
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end

end
