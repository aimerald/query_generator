RSpec.describe QueryGenerator do
  it 'define generated standard sql query' do
    table = QueryGenerator::Table.new('products', strict: false)
    expect(table.select.query).to eq('SELECT * FROM products')
  end

  it 'define generated query using select stmt' do
    table = QueryGenerator::Table.new('products', strict: false)
    table.select(
      [:id],
      [:price, as: :price]
    )
    expect(table.query).to eq('SELECT id, price AS price FROM products')
  end

  it 'define where stmt using eq' do
    table = QueryGenerator::Table.new('products')
    table.select.where(
      [:id, :eq, 1]
    )
    expect(table.query).to eq('SELECT * FROM products WHERE id = 1')
  end

  it 'define where stmt using not_eq' do
    table = QueryGenerator::Table.new('products')
    table.select.where(
      [:id, :not_eq, 1]
    )
    expect(table.query).to eq('SELECT * FROM products WHERE id != 1')
  end

  it 'define where stmt using in' do
    table = QueryGenerator::Table.new('products')
    table.select.where(
      [:id, :in, [1, 2, 3]]
    )
    expect(table.query).to eq('SELECT * FROM products WHERE id IN (1, 2, 3)')
  end

  it 'define where stmt using between' do
    table = QueryGenerator::Table.new('products')
    from = Date.parse('2019-06-01')
    to = Date.parse('2019-06-22')
    table.select.where(
      [:created_at, :between, [from, to]]
    )
    expect(table.query).to eq("SELECT * FROM products WHERE created_at BETWEEN '#{from}' AND '#{to}'")
  end

  it 'to_s raise error when does not use where stmt when strict mode' do
    table = QueryGenerator::Table.new('products')
    expect { table.select.to_s }.to raise_error(StandardError)
  end
end
