# frozen_string_literal: true
require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::UnionBase do
  it 'inherits from StructLikeBase' do
    GirFFI::StructBase.must_include GirFFI::StructLikeBase
  end

  describe 'new' do
    it 'creates an instance with an owned struct' do
      instance = GIMarshallingTests::Union.new
      instance.struct.must_be :owned?
    end

    it 'ensures the wrapped pointer is not autoreleased' do
      instance = GIMarshallingTests::Union.new
      instance.to_ptr.wont_be :autorelease?
    end
  end
end
