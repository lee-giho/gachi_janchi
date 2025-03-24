class Translation {
  static const Map<String, String> ingredientMap = {
    "garlic": "마늘",
    "meat": "고기",
    "mushroom": "버섯",
    "tomato": "토마토",
    "eggplant": "가지",
    "egg": "계란",
    "carrot": "당근",
    "pizza": "피자",
    "banana": "바나나",
    "pineapple": "파인애플",
    "strawberry": "딸기",
    "milk": "우유",
    "corn": "옥수수",
    "cake": "케이크",
  };

  static const Map<String, String> collectionMap = {
    "kimchiStew": "김치찌개",
    "soybeanPasteStew": "된장찌개",
    "bulgogi": "불고기",
    "fruitSalad": "과일 샐러드",
    "omurice": "오므라이스",
    "padThai": "팟타이",
    "tteokbokki": "떡볶이",
    "bibimbap": "비빔밥",
    "seafoodPancake": "해물파전",
    "steak": "스테이크",
    "friedRice": "볶음밥",
    "spicySquid": "오징어볶음",
    "curryRice": "카레라이스",
    "lasagna": "라자냐",
    "gambas": "감바스",
    "creamSoup": "크림스프",
    "pancake": "팬케이크",
    "fruitJuice": "과일주스",
    "smoothieBowl": "스무디볼",
  };

  /// 영어 재료명 -> 한글 재료명
  static String translateIngredient(String englishName) {
    return ingredientMap[englishName] ?? englishName;
  }

  /// 영어 컬렉션명 -> 한글 컬렉션명
  static String translateCollection(String englishName) {
    return collectionMap[englishName] ?? englishName;
  }
}