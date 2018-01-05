require 'graphed_fuzzy_search'
RSpec.describe GraphedFuzzySearch do
  # XXX:

  let(:items) { %w(john-appleseed john-doe jonathan-doe alice-eve eve-doe) }
  let(:collection) { GraphedFuzzySearch.new(items) }

  describe "#query" do
    specify "'d'" do
      expect(collection.query('d')).to eq(["john-doe", "jonathan-doe", "eve-doe"])
    end
    specify "'dj'" do
      expect(collection.query('dj')).to eq(["john-doe", "jonathan-doe"])
    end
    specify "'djoh'" do
      expect(collection.query('djoh')).to eq(["john-doe"])
    end
    specify "'a'" do
      expect(collection.query('a')).to eq(["alice-eve", "john-appleseed"])
    end
    specify "'alice-eve'" do
      expect(collection.query('alice-eve')).to eq(["alice-eve"])
    end
  end
end
