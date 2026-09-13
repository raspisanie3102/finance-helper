#!/usr/bin/env python3
"""Подбирает фото блюд через открытый API TheMealDB и сохраняет в assets.

Для каждого блюда — список англоязычных запросов; берём первое совпадение.
Если ни один запрос не дал результата — блюдо остаётся без фото (UI покажет эмодзи).
"""
import json
import os
import subprocess
import urllib.parse

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "images", "dishes")
API = "https://www.themealdb.com/api/json/v1/1/search.php?s="

# русское название -> варианты англоязычных запросов
QUERIES = {
    "oatmeal_berries": ["oatmeal", "porridge", "muesli"],
    "omelette_veg": ["omelette", "tortilla"],
    "syrniki": ["syrniki", "pancakes", "scotch pancakes"],
    "cottage_honey": ["cottage cheese", "yogurt", "breakfast"],
    "pasta_chicken_veg": ["carbonara", "macaroni", "fajita"],
    "chicken_soup": ["chicken soup", "chicken noodle soup"],
    "buckwheat_cutlet": ["meatballs", "rissoles"],
    "caesar": ["caesar salad", "ceaser salad", "salad"],
    "baked_fish": ["baked fish", "fish", "trout"],
    "pasta_chicken": ["spaghetti", "pasta"],
    "potato_casserole": ["shepherd's pie", "cottage pie", "potato"],
    "turkey_rice": ["turkey", "rice chicken"],
    "poke_salmon": ["poke", "salmon", "sushi"],
    "borscht": ["borscht", "beef soup", "soup"],
    "pancakes_curd": ["crepe", "pancakes"],
    "buckwheat_mushroom": ["mushroom", "risotto"],
}

SLUGS = {
    "oatmeal_berries": "Овсянка с ягодами",
    "omelette_veg": "Омлет с овощами",
    "syrniki": "Сырники со сметаной",
    "cottage_honey": "Творог с мёдом и орехами",
    "pasta_chicken_veg": "Паста с курицей и овощами",
    "chicken_soup": "Куриный суп с лапшой",
    "buckwheat_cutlet": "Гречка с котлетой",
    "caesar": "Салат «Цезарь» с курицей",
    "baked_fish": "Запечённая рыба с овощами",
    "pasta_chicken": "Паста с курицей",
    "potato_casserole": "Картофельная запеканка с фаршем",
    "turkey_rice": "Тушёная индейка с рисом",
    "poke_salmon": "Поке с лососем",
    "borscht": "Борщ с говядиной",
    "pancakes_curd": "Блины с творогом",
    "buckwheat_mushroom": "Гречневая каша с грибами",
}


def fetch(url: str) -> bytes:
    # через curl: у системного python нет доверенных корневых сертификатов
    out = subprocess.run(
        ["curl", "-sf", "--max-time", "20", "-A", "Mozilla/5.0", url],
        capture_output=True,
        check=True,
    )
    return out.stdout


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    mapping = {}
    for slug, queries in QUERIES.items():
        path = os.path.join(OUT_DIR, f"{slug}.jpg")
        if os.path.exists(path):  # уже скачано ранее
            mapping[slug] = f"assets/images/dishes/{slug}.jpg"
            print(f"• {slug}: уже есть")
            continue
        found = None
        for q in queries:
            try:
                data = json.loads(fetch(API + urllib.parse.quote(q)))
            except Exception as e:
                print(f"  ! запрос «{q}» не удался: {e}")
                continue
            meals = data.get("meals")
            if meals:
                found = meals[0]["strMealThumb"]
                print(f"• {slug} ← «{found.split('/')[-1]}» (запрос: {q})")
                break
        if not found:
            print(f"× {slug}: фото не найдено")
            continue
        try:
            img = fetch(found)
            with open(path, "wb") as f:
                f.write(img)
            mapping[slug] = f"assets/images/dishes/{slug}.jpg"
        except Exception as e:
            print(f"  ! скачивание не удалось: {e}")

    print("\nИтог (для data.dart):")
    for slug in SLUGS:
        if slug in mapping:
            print(f"  '{SLUGS[slug]}': '{mapping[slug]}',")


if __name__ == "__main__":
    main()
