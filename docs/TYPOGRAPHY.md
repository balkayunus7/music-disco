
# Ara — tipografi ve temel görünüm

Son siyah-beyaz ana uygulama ve seçilen “Ses izi” loading tasarımından çıkarılan değerler. Ölçüler CSS px; native uygulamada mantıksal ekran birimi olarak ele alınır, ekranın piksel yoğunluğuyla çarpılmaz. Kullanıcının sistem yazı ölçeği korunmalıdır.

## Font aileleri

- Archivo Black: büyük başlıklar, ara logosu, büyük şarkı/sanatçı başlıkları. Font zaten kalın tasarlanmıştır; kaynakta weight 400 kullanılıyor. Sentetik 800/900 uygulamayın.
- Manrope: açıklamalar, butonlar, giriş alanları, sekmeler ve etiketler. Yüklenen ağırlıklar 400, 500, 600, 700, 800.
- Font yüklenemezse kaynakta sans-serif/Arial yedekleri var; görsel eşleşme için asıl fontları kullanın.

## Tipografi rolleri

| Rol | Font | Boyut | Weight | Satır yüksekliği çarpanı | Harf aralığı |
| --- | --- | ---: | ---: | ---: | ---: |
| Genel ekran başlığı | Archivo Black | en fazla 36 | 400 | 1.02 | -1.8 |
| Keşfet ana başlığı | Archivo Black | en fazla 38 | 400 | 1.02 | -1.8 |
| Ayarlar başlığı | Archivo Black | en fazla 32 | 400 | 1.02 | -1.8 |
| Oynatıcı ekran başlığı | Archivo Black | en fazla 30 | 400 | 1.05 | -1.8 |
| Loading başlığı | Archivo Black | en fazla 34 | 400 | 1.05 | -1.5 |
| Loading sonuç başlığı | Archivo Black | en fazla 30 | 400 | 1.15 | -1.2 |
| Şarkı adı (oynatıcı) | Archivo Black | 26 | 400 | 1.2 | -1 |
| Sanatçı referans kartı başlığı | Archivo Black | 25 | 400 | 1.5 (kalıtılan) | -1 |
| Profil adı | Archivo Black | 23 | 400 | 1.2 | -0.8 |
| Alt panel başlığı | Archivo Black | 29 | 400 | 1.15 | -1 |
| Ana uygulama logosu | Archivo Black | 31 | 400 | 0.9 | -2 |
| Loading logosu | Archivo Black | 30 | 400 | 0.9 | -2 |
| Keşif yolu kart başlığı | Manrope | 17 | 800 | 1.3 | -0.7 |
| Tercihler bölüm başlığı | Manrope | 16 | 800 | 1.5 | -0.5 |
| Ana açıklama | Manrope | 13 | 400 | 1.65 | 0 |
| Loading açıklaması | Manrope | 13 | 400 | 1.7 | 0 |
| Ana buton | Manrope | 14 | 800 | 1.5 | 0 |
| Loading ana butonu | Manrope | 13 | 800 | 1.5 | 0 |
| Oynatıcı kaydet/sonraki butonları | Manrope | 12 | 800 | 1.5 | 0 |
| Arama ve profil giriş alanı | Manrope | 16 | 400 | 1.5 | 0 |
| Liste öğesi başlığı | Manrope | 13 | 700 | 1.3 | 0 |
| Ayarlar satır başlığı | Manrope | 13 | 700 | 1.5 | 0 |
| İkincil açıklama | Manrope | 11 | 400 | 1.4–1.6 | 0 |
| Alt menü etiketi | Manrope | 11 | 700 | 1.5 | 0 |
| Loading durum metni | Manrope | 12 | 400 | 1.5 | 0 |
| Loading dipnotu | Manrope | 11 | 400 | 1.7 | 0 |
| Ana uygulama küçük üst etiketi | Manrope | 10 | 700 | 1.5 | +1.2 / +1.5 |
| Loading küçük üst etiketi | Manrope | 9 | 700 | 1.5 | +1.5 |
| Loading 01–05 numaraları | Manrope | 9 | 500 | 1.5 | +1.3 |

Satır yüksekliği bir çarpandır: 13 × 1.7 = 22.1 px. Harf aralıkları px/mantıksal birimdir, yüzde değildir.

## Başlıkların responsive hesabı

`W`, yatay padding ve border çıkarıldıktan sonra kalan içerik genişliğidir; tüm ekran genişliği değildir.

```
general = min(36, W * 0.117)
home = min(38, W * 0.12)
settings = min(32, W * 0.107)
player = min(30, W * 0.096)
loading = min(34, W * 0.106)
loadingResults = min(30, W * 0.091)
```

Başlıklar, görsel değerlendirme sonrası tek satıra alınmış ve kompakt ölçekten 2 mantıksal birim büyütülmüştür; yukarıdaki değerler güncel uygulama değerleridir. İki başlık bölümü boşlukla ayrılır; ikinci bölüm gri kalır. Sistem yazı ölçeği korunur, sığmayan metin üç noktayla kısaltılır ve erişilebilirlik etiketi tam başlığı içerir.

370 px ve altındaki önizleme genişliklerinde ana ekran başlık harf aralığı -1.5, loading başlığı -1.3 olur. Şarkı adı 23, profil adı 20, keşif yolu kart başlığı 15 olur. Gerçek uygulamada bu dar ekran koşulunu mevcut responsive sistemine uyarlayın.

8–10 px yazılar dekoratif baskı, numara ve üst etiketlerde mevcut. Bunlar görsel referans değerleridir. Üretimde işlevsel veya okunması gerekli etiketleri tercihen en az 11–12 mantıksal birime taşıyın. Başlık stilini bütün metinlere uygulamayın.

## Renkler

| Kullanım | Ana uygulama | Ses izi |
| --- | --- | --- |
| Zemin | #101010 | #101010 |
| Ana metin | #F3F2EE | #EEEDE8 |
| Başlığın ikinci satırı | #777777 | #727272 |
| Açıklama | #AAAAAA | #AAAAAA |
| İkincil metin | #888888 / #999999 | #888888 |
| Durum metni | — | #BFBFBF |
| Dalga çubukları | — | #DDDDDD |
| Kart yüzeyi | #191919 / #1B1B1B | kart kullanılmıyor |
| Ana buton zemini | #EEEDE8 | #E7E6E0 |
| Ana buton metni | #151515 | #171717 |

Yarı saydam yüzeyler beyazın %4–10 opaklığı, ince çizgiler beyazın %6–12 opaklığı ile oluşturuluyor. Kaynaktaki #FFFFFF10 gibi 8 haneli hex, CSS RRGGBBAA sırasındadır; Flutter 0xAARRGGBB sırasıyla karıştırmayın.

## Ölçüler

- Ana uygulama yatay padding: 23; dar ekranda 17.
- Loading yatay padding: 25; dar ekranda 18.
- Ana buton: minimum yükseklik 55, radius 16.
- Loading butonu: minimum yükseklik 53, radius 15.
- Arama alanı: minimum yükseklik 54, radius 14.
- Profil giriş alanı: minimum yükseklik 55, radius 14.
- Küçük seçim kartları: radius 12–13; büyük kartlar çoğunlukla 16–19.
- Loading dalgası: 5 satır, satır başına 49 çubuk; yükseklik 29, genişlik en fazla 3, aralık 2; dar ekranda aralık 1.
- Dokunma alanı: minimum 44 × 44.
- Önizlemedeki 36 px telefon çerçevesi köşesi ve dış noktalı zemin gerçek uygulamaya taşınmaz.

Kesin ekran bazlı ayrıntılar için kaynak HTML dosyalarının ilgili CSS kuralları esas alınmalıdır. Bu belge tasarımı özetler; gerçek proje framework'üne henüz entegre edilmiş tema dosyası değildir.
