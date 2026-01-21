import json

json_path = 'assets/cards/cards_v0_1.json'
output_path = 'database/seeds/cards_seed.sql'

type_map = {
    'tropa': 'unit',
    'feitico': 'spell',
    'construcao': 'building'
}

rarity_map = {
    'comum': 'common',
    'rara': 'rare',
    'epica': 'epic',
    'lendaria': 'legendary'
}

with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

cards = data['cards']

sql_lines = []
sql_lines.append("-- Seed Cards from cards_v0_1.json")
sql_lines.append("INSERT INTO public.cards (id, name, type, rarity, cost, asset_path, base_stats) VALUES")

values = []
for card in cards:
    c_id = card['id']
    name = card['nome'].replace("'", "''")
    c_type = type_map.get(card['tipo'], 'unit')
    rarity = rarity_map.get(card['raridade'], 'common')
    cost = card['custo']
    asset = card.get('image_path', '')
    
    # Base stats (exclude mapped fields)
    stats = {k: v for k, v in card.items() if k not in ['id', 'nome', 'tipo', 'raridade', 'custo', 'image_path']}
    stats_json = json.dumps(stats).replace("'", "''")
    
    values.append(f"('{c_id}', '{name}', '{c_type}', '{rarity}', {cost}, '{asset}', '{stats_json}'::jsonb)")

sql_lines.append(",\n".join(values))
sql_lines.append("ON CONFLICT (id) DO UPDATE SET")
sql_lines.append("    name = EXCLUDED.name,")
sql_lines.append("    type = EXCLUDED.type,")
sql_lines.append("    rarity = EXCLUDED.rarity,")
sql_lines.append("    cost = EXCLUDED.cost,")
sql_lines.append("    asset_path = EXCLUDED.asset_path,")
sql_lines.append("    base_stats = EXCLUDED.base_stats;")

with open(output_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql_lines))

print(f"Generated SQL seed at {output_path}")
