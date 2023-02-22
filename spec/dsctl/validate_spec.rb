
describe "Validate Schemas" do
  let(:schemas_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'schemas') }

  it "validates all schemas" do
    expect(Dsctl::Validate.new(schemas_path: schemas_path).call).to eq(true)
  end
end