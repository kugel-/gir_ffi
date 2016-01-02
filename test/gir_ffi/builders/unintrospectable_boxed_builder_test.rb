require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::Builders::UnintrospectableBoxedBuilder do
  let(:instance) do
    GIMarshallingTests::PropertiesObject.new.tap do |it|
      it.some_boxed_glist = [1, 2, 3]
    end
  end

  let(:gvalue) { instance.get_property('some-boxed-glist') }
  let(:gtype) { gvalue.current_gtype }
  let(:info) { GirFFI::UnintrospectableBoxedInfo.new(gtype) }
  let(:bldr) { GirFFI::Builders::UnintrospectableBoxedBuilder.new(info) }
  let(:klass) { bldr.build_class }

  it 'builds a class' do
    klass.must_be_instance_of Class
  end

  it 'builds a class derived from GirFFI::BoxedBase' do
    klass.ancestors.must_include GirFFI::BoxedBase
  end

  it 'returns the same class when built again' do
    other_bldr = GirFFI::Builders::UnintrospectableBoxedBuilder.new(info)
    other_klass = other_bldr.build_class

    other_klass.must_equal klass
  end
end
