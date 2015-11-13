class PolymorphicSerializer < EasySerializer::Base
  # cache true
  attribute :segment_type do |object|
    object.subject.class.name
  end
  attribute :segment_id do |object|
    object.id
  end
  attribute :date
  attribute :subject,
            key: false,
            serializer: proc {|serializer| serializer.serializer_for_subject },
            cache: true

  def serializer_for_subject
    namespace = self.class.name.gsub(self.class.name.demodulize, '')
    object_name = klass_ins.subject_type.demodulize
    if const = "#{namespace}#{object_name}Serializer".safe_constantize
      const
    else
      "#{object_name}Serializer".constantize
    end
  end
end
