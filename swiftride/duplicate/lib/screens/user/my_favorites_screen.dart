// lib/screens/user/my_favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/utils/constants.dart' show kNavy, kGold, kSurf, kSurf2, kText, kTextS, kError, kSuccess, AppColors, kAllCars, kCategories;

class MyFavoritesScreen extends StatefulWidget {
  const MyFavoritesScreen({super.key});
  @override State<MyFavoritesScreen> createState() => _State();
}
class _State extends State<MyFavoritesScreen> {
  final List<Map<String,dynamic>> _cars = [
    kAllCars[0], kAllCars[4], kAllCars[5],
  ];
  void _remove(String id) {
    final car = _cars.firstWhere((c) => c['id']==id);
    setState(() => _cars.removeWhere((c) => c['id']==id));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Removed from favorites'),
      backgroundColor: kSurf,
      action: SnackBarAction(label:'Undo',textColor:kGold,onPressed:()=>setState(()=>_cars.add(car))),
    ));
  }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: kNavy,
    appBar: AppBar(title: Text('Favorites (${_cars.length})')),
    body: _cars.isEmpty
        ? Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
            const Icon(Icons.favorite_border_rounded,color:kTextS,size:60),
            const SizedBox(height:14),
            const Text('No favorites yet',style:TextStyle(color:kTextS,fontSize:16,fontWeight:FontWeight.w700)),
            const SizedBox(height:8),
            const Text('Tap ♡ on any car to save it here',style:TextStyle(color:kTextS,fontSize:13)),
          ]))
        : ListView.builder(padding:const EdgeInsets.all(16),itemCount:_cars.length,
            itemBuilder:(_,i)=>_FavCard(car:_cars[i],
              onRemove:()=>_remove(_cars[i]['id'] as String),
              onBook:()=>Navigator.pushNamed(context,'/user/car-detail',arguments:_cars[i]))),
  );
}
class _FavCard extends StatelessWidget {
  final Map<String,dynamic> car; final VoidCallback onRemove,onBook;
  const _FavCard({required this.car,required this.onRemove,required this.onBook});
  @override Widget build(BuildContext context)=>Container(
    margin:const EdgeInsets.only(bottom:12),
    decoration:BoxDecoration(color:kSurf,borderRadius:BorderRadius.circular(16)),
    child:Row(children:[
      ClipRRect(borderRadius:const BorderRadius.horizontal(left:Radius.circular(16)),
        child:Container(width:90,height:90,color:Color(car['color'] as int),
          child:const Icon(Icons.directions_car_rounded,color:Colors.white,size:38))),
      Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:14,vertical:12),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(car['name'] as String,style:const TextStyle(color:kText,fontWeight:FontWeight.w700,fontSize:14)),
          const SizedBox(height:3),
          Row(children:[
            const Icon(Icons.star_rounded,color:kGold,size:13),
            const SizedBox(width:3),
            Text('${car['rating']}',style:const TextStyle(color:kTextS,fontSize:12)),
            const SizedBox(width:8),
            Text(car['category'] as String,style:const TextStyle(color:kTextS,fontSize:12)),
          ]),
          const SizedBox(height:8),
          Row(children:[
            RichText(text:TextSpan(children:[
              TextSpan(text:'\$${car['price']}',style:const TextStyle(color:kGold,fontWeight:FontWeight.w800,fontSize:15)),
              const TextSpan(text:'/day',style:TextStyle(color:kTextS,fontSize:11)),
            ])),
            const Spacer(),
            GestureDetector(onTap:onRemove,child:const Icon(Icons.favorite_rounded,color:kError,size:20)),
            const SizedBox(width:10),
            GestureDetector(onTap:onBook,child:Container(
              padding:const EdgeInsets.symmetric(horizontal:14,vertical:6),
              decoration:BoxDecoration(color:kGold,borderRadius:BorderRadius.circular(8)),
              child:const Text('Book',style:TextStyle(color:Colors.black,fontSize:12,fontWeight:FontWeight.w700)))),
          ]),
        ]))),
    ]),
  );
}
