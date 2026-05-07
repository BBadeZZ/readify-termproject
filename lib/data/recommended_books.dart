class RecommendedBook {
  final String title;
  final String author;
  final String genre;
  final String description;
  final int pages;
  final double rating;
  final String coverUrl;

  RecommendedBook({
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
    required this.pages,
    required this.rating,
    required this.coverUrl,
  });
}

List<RecommendedBook> recommendedBooks = [
  RecommendedBook(
    title: 'Kürk Mantolu Madonna',
    author: 'Sabahattin Ali',
    genre: 'Turkish Classic',
    pages: 160,
    rating: 4.9,
    coverUrl: '',
    description:
    'A deeply emotional Turkish classic about love, loneliness, inner conflict and unforgettable memories.',
  ),
  RecommendedBook(
    title: 'İçimizdeki Şeytan',
    author: 'Sabahattin Ali',
    genre: 'Turkish Classic',
    pages: 256,
    rating: 4.8,
    coverUrl: '',
    description:
    'A strong psychological novel about human weakness, society, love and the inner excuses people create.',
  ),
  RecommendedBook(
    title: 'Kuyucaklı Yusuf',
    author: 'Sabahattin Ali',
    genre: 'Turkish Classic',
    pages: 220,
    rating: 4.7,
    coverUrl: '',
    description:
    'A powerful novel about love, injustice, loneliness and social pressure in Anatolian life.',
  ),

  RecommendedBook(
    title: 'Yaprak Dökümü',
    author: 'Reşat Nuri Güntekin',
    genre: 'Turkish Classic',
    pages: 176,
    rating: 4.6,
    coverUrl: '',
    description:
    'A family-centered Turkish novel about modernization, changing values and the collapse of a household.',
  ),
  RecommendedBook(
    title: 'Acımak',
    author: 'Reşat Nuri Güntekin',
    genre: 'Turkish Classic',
    pages: 160,
    rating: 4.5,
    coverUrl: '',
    description:
    'A touching novel about compassion, misunderstanding, family relationships and hidden truths.',
  ),
  RecommendedBook(
    title: 'Aşk-ı Memnu',
    author: 'Halit Ziya Uşaklıgil',
    genre: 'Turkish Classic',
    pages: 400,
    rating: 4.7,
    coverUrl: '',
    description:
    'One of the most important Turkish novels about forbidden love, desire, family and tragedy.',
  ),
  RecommendedBook(
    title: 'Mai ve Siyah',
    author: 'Halit Ziya Uşaklıgil',
    genre: 'Turkish Classic',
    pages: 336,
    rating: 4.5,
    coverUrl: '',
    description:
    'A classic novel about dreams, disappointment, literature and the conflict between idealism and reality.',
  ),
  RecommendedBook(
    title: 'Eylül',
    author: 'Mehmet Rauf',
    genre: 'Turkish Classic',
    pages: 240,
    rating: 4.6,
    coverUrl: '',
    description:
    'Known as one of the first psychological novels in Turkish literature, focusing on love and inner emotions.',
  ),
  RecommendedBook(
    title: 'Araba Sevdası',
    author: 'Recaizade Mahmut Ekrem',
    genre: 'Turkish Classic',
    pages: 240,
    rating: 4.3,
    coverUrl: '',
    description:
    'A satirical Turkish classic about imitation of Western culture, appearance and social misunderstanding.',
  ),
  RecommendedBook(
    title: 'Felatun Bey ile Rakım Efendi',
    author: 'Ahmet Mithat Efendi',
    genre: 'Turkish Classic',
    pages: 192,
    rating: 4.4,
    coverUrl: '',
    description:
    'A classic comparison between false Westernization and balanced intellectual development.',
  ),
  RecommendedBook(
    title: 'İntibah',
    author: 'Namık Kemal',
    genre: 'Turkish Classic',
    pages: 160,
    rating: 4.3,
    coverUrl: '',
    description:
    'An early Turkish novel about love, regret, wrong decisions and moral awakening.',
  ),
  RecommendedBook(
    title: 'Sinekli Bakkal',
    author: 'Halide Edib Adıvar',
    genre: 'Turkish Classic',
    pages: 480,
    rating: 4.5,
    coverUrl: '',
    description:
    'A Turkish classic about tradition, change, identity and social life during the late Ottoman period.',
  ),
  RecommendedBook(
    title: 'Ateşten Gömlek',
    author: 'Halide Edib Adıvar',
    genre: 'Turkish Classic',
    pages: 240,
    rating: 4.6,
    coverUrl: '',
    description:
    'A national struggle novel about war, sacrifice, love and courage during the Turkish War of Independence.',
  ),
  RecommendedBook(
    title: 'Yaban',
    author: 'Yakup Kadri Karaosmanoğlu',
    genre: 'Turkish Classic',
    pages: 224,
    rating: 4.4,
    coverUrl: '',
    description:
    'A significant novel about the gap between intellectuals and Anatolian villagers during the national struggle.',
  ),
  RecommendedBook(
    title: 'Kiralık Konak',
    author: 'Yakup Kadri Karaosmanoğlu',
    genre: 'Turkish Classic',
    pages: 232,
    rating: 4.5,
    coverUrl: '',
    description:
    'A novel about generational conflict, social change and the transformation of Ottoman family life.',
  ),
  RecommendedBook(
    title: 'Dokuzuncu Hariciye Koğuşu',
    author: 'Peyami Safa',
    genre: 'Turkish Classic',
    pages: 128,
    rating: 4.7,
    coverUrl: '',
    description:
    'A psychological novel about illness, fear, hope, love and the inner world of a young patient.',
  ),
  RecommendedBook(
    title: 'Fatih-Harbiye',
    author: 'Peyami Safa',
    genre: 'Turkish Classic',
    pages: 128,
    rating: 4.5,
    coverUrl: '',
    description:
    'A novel about East-West conflict, identity, modernization and emotional confusion.',
  ),
  RecommendedBook(
    title: 'Saatleri Ayarlama Enstitüsü',
    author: 'Ahmet Hamdi Tanpınar',
    genre: 'Turkish Classic',
    pages: 392,
    rating: 4.8,
    coverUrl: '',
    description:
    'A symbolic and ironic Turkish classic about time, modernization, institutions and society.',
  ),
  RecommendedBook(
    title: 'Huzur',
    author: 'Ahmet Hamdi Tanpınar',
    genre: 'Turkish Classic',
    pages: 420,
    rating: 4.6,
    coverUrl: '',
    description:
    'A literary novel about love, Istanbul, music, memory and the spiritual conflicts of modern life.',
  ),
  RecommendedBook(
    title: 'Tutunamayanlar',
    author: 'Oğuz Atay',
    genre: 'Turkish Modern Classic',
    pages: 724,
    rating: 4.8,
    coverUrl: '',
    description:
    'A major modern Turkish novel about alienation, identity, friendship and the struggle of people who cannot fit in.',
  ),
  RecommendedBook(
    title: 'Tehlikeli Oyunlar',
    author: 'Oğuz Atay',
    genre: 'Turkish Modern Classic',
    pages: 480,
    rating: 4.7,
    coverUrl: '',
    description:
    'A modern novel about inner conflicts, imagination, loneliness and the games people play with themselves.',
  ),
  RecommendedBook(
    title: 'İnce Memed',
    author: 'Yaşar Kemal',
    genre: 'Turkish Classic',
    pages: 436,
    rating: 4.9,
    coverUrl: '',
    description:
    'An epic Turkish novel about rebellion, justice, oppression and the legendary character İnce Memed.',
  ),
  RecommendedBook(
    title: 'Yer Demir Gök Bakır',
    author: 'Yaşar Kemal',
    genre: 'Turkish Classic',
    pages: 392,
    rating: 4.6,
    coverUrl: '',
    description:
    'A powerful Anatolian novel about poverty, belief, nature and collective hope.',
  ),
  RecommendedBook(
    title: 'Devlet Ana',
    author: 'Kemal Tahir',
    genre: 'Turkish Classic',
    pages: 624,
    rating: 4.6,
    coverUrl: '',
    description:
    'A historical Turkish novel about the foundation period of the Ottoman state and social structure.',
  ),
  RecommendedBook(
    title: 'Esir Şehrin İnsanları',
    author: 'Kemal Tahir',
    genre: 'Turkish Classic',
    pages: 416,
    rating: 4.5,
    coverUrl: '',
    description:
    'A novel about Istanbul under occupation, resistance, identity and social responsibility.',
  ),
  RecommendedBook(
    title: 'Bereketli Topraklar Üzerinde',
    author: 'Orhan Kemal',
    genre: 'Turkish Classic',
    pages: 376,
    rating: 4.7,
    coverUrl: '',
    description:
    'A realistic novel about workers, poverty, migration and exploitation in Turkish society.',
  ),
  RecommendedBook(
    title: 'Hanımın Çiftliği',
    author: 'Orhan Kemal',
    genre: 'Turkish Classic',
    pages: 368,
    rating: 4.6,
    coverUrl: '',
    description:
    'A social novel about class differences, power, love and rural life.',
  ),
  RecommendedBook(
    title: 'Memleket Hikâyeleri',
    author: 'Refik Halit Karay',
    genre: 'Turkish Classic',
    pages: 160,
    rating: 4.5,
    coverUrl: '',
    description:
    'A collection of stories reflecting Anatolian people, social life and human character.',
  ),
  RecommendedBook(
    title: 'Çalıkuşu',
    author: 'Reşat Nuri Güntekin',
    genre: 'Romance',
    pages: 408,
    rating: 4.8,
    coverUrl: '',
    description:
    'A romantic and emotional story of Feride, one of the most memorable characters in Turkish literature.',
  ),

  RecommendedBook(
    title: 'Satranç',
    author: 'Stefan Zweig',
    genre: 'Novel',
    pages: 88,
    rating: 4.6,
    coverUrl: '',
    description:
    'A psychological novella about chess, pressure, isolation and mental struggle.',
  ),
  RecommendedBook(
    title: 'Küçük Prens',
    author: 'Antoine de Saint-Exupéry',
    genre: 'Classic',
    pages: 112,
    rating: 4.8,
    coverUrl: '',
    description:
    'A poetic classic about childhood, friendship, love and seeing the world with the heart.',
  ),
  RecommendedBook(
    title: 'Şeker Portakalı',
    author: 'José Mauro de Vasconcelos',
    genre: 'Novel',
    pages: 200,
    rating: 4.8,
    coverUrl: '',
    description:
    'A touching novel about childhood, imagination, poverty and emotional growth.',
  ),

  RecommendedBook(
    title: 'Atomic Habits',
    author: 'James Clear',
    genre: 'Personal Development',
    pages: 320,
    rating: 4.8,
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg',
    description:
    'A practical book about building good habits, breaking bad habits, and improving yourself with small daily actions.',
  ),
  RecommendedBook(
    title: 'The Alchemist',
    author: 'Paulo Coelho',
    genre: 'Novel',
    pages: 208,
    rating: 4.6,
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780061122415-L.jpg',
    description:
    'A story about dreams, destiny, courage, and following your personal legend.',
  ),
  RecommendedBook(
    title: '1984',
    author: 'George Orwell',
    genre: 'Dystopian',
    pages: 328,
    rating: 4.7,
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg',
    description:
    'A powerful dystopian novel about surveillance, control, freedom, and truth.',
  ),
  RecommendedBook(
    title: 'Clean Code',
    author: 'Robert C. Martin',
    genre: 'Programming',
    pages: 464,
    rating: 4.5,
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg',
    description:
    'A software engineering book that explains how to write clean, readable, and maintainable code.',
  ),
  RecommendedBook(
    title: 'The Psychology of Money',
    author: 'Morgan Housel',
    genre: 'Finance',
    pages: 256,
    rating: 4.7,
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780857197689-L.jpg',
    description:
    'A book about money behavior, financial decisions, wealth, and long-term thinking.',
  ),

  RecommendedBook(
    title: 'Deep Work',
    author: 'Cal Newport',
    genre: 'Productivity',
    pages: 304,
    rating: 4.6,
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9781455586691-L.jpg',
    description:
    'A productivity book about focus, concentration, and working without distraction.',
  ),
];