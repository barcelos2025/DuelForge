import '../models/avatar_def.dart';

class AvatarRegistry {
  static final AvatarRegistry instance = AvatarRegistry._();
  AvatarRegistry._();

  final Map<String, AvatarDef> _avatars = {
    'warrior_m': AvatarDef(
      id: 'warrior_m',
      name: 'Bjorn',
      description: 'Um veterano endurecido pelas batalhas nos Desertos Congelados. Ele busca redenção por um clã perdido, carregando o peso de seus ancestrais em cada golpe de seu machado.',
      assetPath: 'assets/avatars/warrior_m.png',
      classType: 'Guerreiro',
      gender: 'Masculino',
    ),
    'warrior_f': AvatarDef(
      id: 'warrior_f',
      name: 'Astrid',
      description: 'Escudeira da guarda das Valquírias. Ela luta com ferocidade inigualável para provar seu valor a Freya e ganhar seu lugar em Valhalla.',
      assetPath: 'assets/avatars/warrior_f.png',
      classType: 'Guerreira',
      gender: 'Feminino',
    ),
    'archer_m': AvatarDef(
      id: 'archer_m',
      name: 'Leif',
      description: 'Um mestre rastreador da Floresta de Ferro. Dizem que ele nunca erra um alvo e que pode falar com os lobos que caçam ao seu lado.',
      assetPath: 'assets/avatars/archer_m.png',
      classType: 'Arqueiro',
      gender: 'Masculino',
    ),
    'archer_f': AvatarDef(
      id: 'archer_f',
      name: 'Elara',
      description: 'Guardiã da Clareira dos Sussurros. Suas flechas são guiadas pelos espíritos do vento, encontrando brechas nas armaduras mais pesadas.',
      assetPath: 'assets/avatars/archer_f.png',
      classType: 'Arqueira',
      gender: 'Feminino',
    ),
    'mage_m': AvatarDef(
      id: 'mage_m',
      name: 'Erik',
      description: 'Um conjurador de runas que estudou sob os corvos do Pai de Todos. Ele empunha o poder das tempestades, trazendo trovões e relâmpagos.',
      assetPath: 'assets/avatars/mage_m.png',
      classType: 'Mago',
      gender: 'Masculino',
    ),
    'mage_f': AvatarDef(
      id: 'mage_f',
      name: 'Vidente',
      description: 'Uma vidente abençoada com visões do Ragnarok. Ela usa magia de gelo para congelar seus inimigos e proteger os segredos do futuro.',
      assetPath: 'assets/avatars/mage_f.png',
      classType: 'Maga',
      gender: 'Feminino',
    ),
    'guardian_m': AvatarDef(
      id: 'guardian_m',
      name: 'Gunnar',
      description: 'Uma figura imponente vestida com armadura de escamas de dragão. Ele é a muralha inquebrável do Norte, protegendo os fracos com seu escudo.',
      assetPath: 'assets/avatars/guardian_m.png',
      classType: 'Guardião',
      gender: 'Masculino',
    ),
    'guardian_f': AvatarDef(
      id: 'guardian_f',
      name: 'Hilda',
      description: 'Guardiã da Chama Sagrada. Seu escudo brilha com a luz da lareira, oferecendo calor aos aliados e queimando aqueles que ousam atacar.',
      assetPath: 'assets/avatars/guardian_f.png',
      classType: 'Guardiã',
      gender: 'Feminino',
    ),
    'warlock_m': AvatarDef(
      id: 'warlock_m',
      name: 'Sombra de Loki',
      description: 'Um trapaceiro que mexe com magia do caos proibida. Imprevisível e perigoso, ele ri diante do perigo e confunde seus oponentes.',
      assetPath: 'assets/avatars/warlock_m.png',
      classType: 'Bruxo',
      gender: 'Masculino',
    ),
    'warlock_f': AvatarDef(
      id: 'warlock_f',
      name: 'Sigrid',
      description: 'Uma bruxa do pântano que comanda os espíritos dos afogados. Temida por todos que conhecem seu nome, ela tece maldições antigas.',
      assetPath: 'assets/avatars/warlock_f.png',
      classType: 'Bruxa',
      gender: 'Feminino',
    ),
    // --- New Avatars ---
    'berserker_m': AvatarDef(
      id: 'berserker_m',
      name: 'Ivar',
      description: 'Um guerreiro tomado pela fúria de urso. Ele não sente dor, apenas a emoção da batalha e o cheiro de sangue.',
      assetPath: 'assets/avatars/berserker_m.png',
      classType: 'Bárbaro',
      gender: 'Masculino',
    ),
    'berserker_f': AvatarDef(
      id: 'berserker_f',
      name: 'Freydis',
      description: 'Uma donzela do escudo que luta com a ferocidade de uma tempestade. Seus gritos de guerra aterrorizam até os mais bravos.',
      assetPath: 'assets/avatars/berserker_f.png',
      classType: 'Bárbara',
      gender: 'Feminino',
    ),
    'rogue_m': AvatarDef(
      id: 'rogue_m',
      name: 'Knut',
      description: 'Um espião que se move nas sombras. Ele sabe todos os segredos dos nove reinos e usa adagas envenenadas.',
      assetPath: 'assets/avatars/rogue_m.png',
      classType: 'Ladino',
      gender: 'Masculino',
    ),
    'rogue_f': AvatarDef(
      id: 'rogue_f',
      name: 'Ylva',
      description: 'Uma assassina silenciosa como a neve caindo. Ela desaparece antes que seus inimigos percebam que estão mortos.',
      assetPath: 'assets/avatars/rogue_f.png',
      classType: 'Ladina',
      gender: 'Feminino',
    ),
    'shaman_m': AvatarDef(
      id: 'shaman_m',
      name: 'Floki',
      description: 'Um excêntrico construtor e curandeiro que ouve a voz dos deuses nas árvores e nas ondas do mar.',
      assetPath: 'assets/avatars/shaman_m.png',
      classType: 'Xamã',
      gender: 'Masculino',
    ),
    'shaman_f': AvatarDef(
      id: 'shaman_f',
      name: 'Helga',
      description: 'Uma sábia curandeira que canaliza a energia da vida. Ela mantém o equilíbrio entre o mundo dos vivos e dos espíritos.',
      assetPath: 'assets/avatars/shaman_f.png',
      classType: 'Xamã',
      gender: 'Feminino',
    ),
    'einherjar_m': AvatarDef(
      id: 'einherjar_m',
      name: 'Ragnar',
      description: 'Um herói lendário escolhido pelo próprio Odin. Ele festeja em Valhalla e desce para lutar as batalhas mais gloriosas.',
      assetPath: 'assets/avatars/einherjar_m.png',
      classType: 'Einherjar',
      gender: 'Masculino',
    ),
    'valkyrie_f': AvatarDef(
      id: 'valkyrie_f',
      name: 'Brunhilde',
      description: 'A líder das Valquírias. Ela escolhe quem vive e quem morre no campo de batalha, carregando as almas dignas para o céu.',
      assetPath: 'assets/avatars/valkyrie_f.png',
      classType: 'Valquíria',
      gender: 'Feminino',
    ),
    'runemaster_m': AvatarDef(
      id: 'runemaster_m',
      name: 'Eitri',
      description: 'Um anão mestre da forja e das runas antigas. Ele grava magia na pedra e no metal para criar artefatos de poder.',
      assetPath: 'assets/avatars/runemaster_m.png',
      classType: 'Mestre das Runas',
      gender: 'Masculino',
    ),
    'runemaster_f': AvatarDef(
      id: 'runemaster_f',
      name: 'Idunn',
      description: 'Guardiã das maçãs da juventude e dos segredos rúnicos. Sua magia restaura e protege, mantendo a vitalidade dos deuses.',
      assetPath: 'assets/avatars/runemaster_f.png',
      classType: 'Mestra das Runas',
      gender: 'Feminino',
    ),
  };

  List<AvatarDef> getAll() => _avatars.values.toList();
  
  AvatarDef get(String id) => _avatars[id] ?? _avatars['warrior_m']!;
}
