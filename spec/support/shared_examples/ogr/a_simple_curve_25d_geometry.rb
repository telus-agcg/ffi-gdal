# frozen_string_literal: true

RSpec.shared_examples 'a simple curve 2.5D geometry' do
  describe '#x' do
    context 'point exists' do
      it 'returns the value of the point' do
        expect(subject.x(0)).to be_a Float
      end
    end

    context 'point does not exist' do
      it 'raises GDAL::UnsupportedOperation' do
        expect { subject.x(-2) }.to raise_exception GDAL::UnsupportedOperation
      end
    end
  end

  describe '#y' do
    context 'point exists' do
      it 'returns the value of the point' do
        expect(subject.y(0)).to be_a Float
      end
    end

    context 'point does not exist' do
      it 'raises GDAL::UnsupportedOperation' do
        expect { subject.y(-2) }.to raise_exception GDAL::UnsupportedOperation
      end
    end
  end

  describe '#z' do
    context 'point exists' do
      it 'returns the value of the point' do
        expect(subject.z(0)).to be_a Float
      end
    end

    context 'point does not exist' do
      it 'raises GDAL::UnsupportedOperation' do
        expect { subject.z(-2) }.to raise_exception GDAL::UnsupportedOperation
      end
    end
  end

  describe '#add_point' do
    context 'normal number values' do
      it 'adds the point to the geometry' do
        expect { subject.add_point(123.456, 6.54, 0.321) }
          .to change { subject.point_count }
          .by 1
      end
    end

    context 'bad number values' do
      it 'raises' do
        expect { subject.add_point('meow', 'pants', 'party') }.to raise_exception TypeError
      end
    end
  end

  describe '#point' do
    context 'point at index exists' do
      it 'adds the point to the geometry' do
        expect(subject.point(0))
          .to contain_exactly(an_instance_of(Float), an_instance_of(Float), an_instance_of(Float))
      end
    end

    context 'point at index does not exist' do
      it 'raises' do
        expect { subject.point(-1) }.to raise_exception GDAL::UnsupportedOperation
      end
    end
  end

  describe '#set_point' do
    context 'normal number values' do
      it 'adds the point to the geometry' do
        expect { subject.set_point(0, 123.456, 6.54, 0.321) }
          .to change { subject.point(0) }
          .from([an_instance_of(Float), an_instance_of(Float), an_instance_of(Float)])
          .to([123.456, 6.54, 0.321])
      end
    end

    context 'bad index value' do
      it 'raises' do
        expect { subject.set_point(-1, 42, 42, 42) }.to raise_exception GDAL::UnsupportedOperation
      end
    end

    context 'non-numbers for coordinate values' do
      it 'raises' do
        expect { subject.set_point(0, 'stuff', 'things', 'choses') }.to raise_exception TypeError
      end
    end
  end

  describe '#points' do
    # This is checked via RBS, but seemed worth having something that actually
    # calls the method, just to make sure pointer-passing and Array-remapping
    # is happy there.
    it 'returns a 3-element Array for each point' do
      expect(subject.points.first)
        .to contain_exactly(an_instance_of(Float), an_instance_of(Float), an_instance_of(Float))
    end
  end

  describe '#point_count=, #point_count' do
    context 'valid value' do
      it 'changes the value of #point_count' do
        initial_count = subject.point_count

        expect { subject.point_count = 42 }
          .to change { subject.point_count }
          .from(initial_count)
          .to(42)
      end
    end

    context 'negative value' do
      it 'sets the value?!' do
        initial_count = subject.point_count

        expect { subject.point_count = -1 }
          .to change { subject.point_count }
          .from(initial_count)
          .to(-1)
      end
    end
  end
end
