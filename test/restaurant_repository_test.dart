import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/features/restaurant_list/model/restaurant.dart';
import 'package:food_delivery/features/restaurant_list/repository/restaurant_repository.dart';
import 'package:dio/dio.dart';

import 'auth_repository_test.dart' show StubAdapter;

RestaurantRepository repoWith(StubAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
    ..httpClientAdapter = adapter;
  return RestaurantRepository(dio);
}

const _restaurants = [
  {
    'restaurantID': 1,
    'restaurantName': 'Paradise Biryani',
    'address': 'Hyderabad, Secunderabad, Telangana',
    'type': 'Biryani',
    'parkingLot': true,
  },
  {
    'restaurantID': 2,
    'restaurantName': 'Britannia & Co.',
    'address': 'Mumbai, Ballard, Maharashtra',
    'type': 'Parsi Cuisine',
    'parkingLot': false,
  },
];

const _items = [
  {'restaurantID': 1, 'imageUrl': 'https://img/first.jpg'},
  {'restaurantID': 1, 'imageUrl': 'https://img/second.jpg'},
  {'restaurantID': 1, 'imageUrl': 'https://img/third.jpg'},
  {'restaurantID': 2, 'imageUrl': 'https://img/other.jpg'},
];

void main() {
  group('city', () {
    test('takes the first segment of the address', () {
      const r = Restaurant(
        restaurantID: 1,
        restaurantName: 'X',
        address: 'Jaipur, Amber Fort, Rajasthan',
        type: 'Rajasthani',
        parkingLot: true,
      );

      expect(r.city, 'Jaipur');
    });

    test('falls back to the whole address when there is no comma', () {
      const r = Restaurant(
        restaurantID: 1,
        restaurantName: 'X',
        address: 'Hyderabad',
        type: 'Biryani',
        parkingLot: true,
      );

      expect(r.city, 'Hyderabad');
    });
  });

  group('getAllRestaurants', () {
    test('merges a photo and a dish count onto each restaurant', () async {
      final adapter = StubAdapter({
        '/Restaurant': (200, _restaurants),
        '/Restaurant/items': (200, _items),
      });

      final result = await repoWith(adapter).getAllRestaurants();

      expect(result, hasLength(2));
      // The FIRST matching item supplies the photo.
      expect(result[0].imageUrl, 'https://img/first.jpg');
      expect(result[0].dishCount, 3);
      expect(result[1].imageUrl, 'https://img/other.jpg');
      expect(result[1].dishCount, 1);
    });

    test('still lists restaurants when the items call fails', () async {
      final adapter = StubAdapter({
        '/Restaurant': (200, _restaurants),
        // /Restaurant/items deliberately absent -> the stub answers 404.
      });

      final result = await repoWith(adapter).getAllRestaurants();

      // Photos are enrichment; losing them must not cost the whole screen.
      expect(result, hasLength(2));
      expect(result[0].restaurantName, 'Paradise Biryani');
      expect(result[0].imageUrl, isNull);
      expect(result[0].dishCount, 0);
    });

    test('fails when the restaurant call itself fails', () async {
      final adapter = StubAdapter({'/Restaurant/items': (200, _items)});

      expect(
        () => repoWith(adapter).getAllRestaurants(),
        throwsA(isA<Exception>()),
      );
    });

    test('tolerates malformed item rows', () async {
      final adapter = StubAdapter({
        '/Restaurant': (200, _restaurants),
        '/Restaurant/items': (
          200,
          [
            'not a map',
            {'restaurantID': 'not an int'},
            {'restaurantID': 1, 'imageUrl': ''},
            {'restaurantID': 1, 'imageUrl': 'https://img/good.jpg'},
          ],
        ),
      });

      final result = await repoWith(adapter).getAllRestaurants();

      // The empty imageUrl is skipped, the good one wins, and the two junk
      // rows neither crash nor inflate the count.
      expect(result[0].imageUrl, 'https://img/good.jpg');
      expect(result[0].dishCount, 2);
    });
  });

  test('distinctTypes are unique and sorted', () {
    final types = Restaurant.distinctTypes([
      const Restaurant(
        restaurantID: 1,
        restaurantName: 'A',
        address: 'x',
        type: 'Mughlai',
        parkingLot: true,
      ),
      const Restaurant(
        restaurantID: 2,
        restaurantName: 'B',
        address: 'y',
        type: 'Biryani',
        parkingLot: true,
      ),
      const Restaurant(
        restaurantID: 3,
        restaurantName: 'C',
        address: 'z',
        type: 'Biryani',
        parkingLot: false,
      ),
    ]);

    expect(types, ['Biryani', 'Mughlai']);
  });
}
