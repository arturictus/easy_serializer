class PolymorphicSerializer < EasySerializer::Base
  cache true
  attribute :segment_type do |object|
    object.subject.class.name
  end
  attribute :segment_id do |object|
    object.id
  end
  attribute :date
  attribute :subject,
            key: false,
            serializer: proc { serializer_for_subject },
            cache: true

  def serializer_for_subject
    case object.subject_type
    when 'PolymophicSubject'
      PolymophicSubjectSerializer
    else
      binding.pry
    end
    # namespace = self.class.name.gsub(self.class.name.demodulize, '')
    # object_name = object.subject_type.demodulize
    # "#{namespace}#{object_name}Serializer".constantize
  end
end
