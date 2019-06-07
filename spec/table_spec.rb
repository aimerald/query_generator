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
    expect { table.select.to_s }.to raise_error(QueryGenerator::StrictModeError)
  end

  it 'run raise error when does not use where stmt when strict mode' do
    table = QueryGenerator::Table.new('products')
    expect { table.select.run }.to raise_error(QueryGenerator::StrictModeError)
  end

  it 'select raise error when using select duplicate' do
    table = QueryGenerator::Table.new('products', strict: false)
    table.select
    expect { table.select }.to raise_error(QueryGenerator::SelectAlreadyUsed)
  end

  it 'or raise error when does not use where before or using' do
    table = QueryGenerator::Table.new('products', strict: false)
    expect { table.or() }.to raise_error(QueryGenerator::WhereDoesNotUsed)
  end

  it 'order_by raise error when differenct asc or desc' do
    table = QueryGenerator::Table.new('products', strict: false)
    expect { table.select.order_by(:id, :aaa) }.to raise_error(QueryGenerator::NotIncludeType)
  end
end
