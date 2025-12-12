# Base serializer class
class ApplicationSerializer
  attr_reader :object, :options

  def initialize(object, **options)
    @object = object
    @options = options
  end

  def as_json
    raise NotImplementedError, 'Subclasses must implement #as_json'
  end
end
