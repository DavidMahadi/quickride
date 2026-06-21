// lib/screens/user/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/utils/constants.dart' show
    kNavy, kGold, kSurf, kSurf2, kText, kTextS, kSuccess, kWarn, kError;

final _fakeBookings = [
  {'ref':'SR0012345','car':'Tesla Model S','cat':'Electric','from':'Jun 15, 2026','to':'Jun 18, 2026','days':3,'total':396,'status':'active','color':0xFF1A237E},
  {'ref':'SR0012500','car':'Porsche 911',  'cat':'Sports',  'from':'Jul 1, 2026', 'to':'Jul 3, 2026', 'days':2,'total':440,'status':'upcoming','color':0xFF4E342E},
  {'ref':'SR0012102','car':'BMW M5',       'cat':'Sports',  'from':'May 20, 2026','to':'May 22, 2026','days':2,'total':330,'status':'completed','color':0xFF880E4F},
  {'ref':'SR0011998','car':'Range Rover',  'cat':'SUV',     'from':'Apr 5, 2026', 'to':'Apr 10, 2026','days':5,'total':990,'status':'completed','color':0xFF1B5E20},
];

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}
class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tc;
  @override void initState() { super.initState(); _tc = TabController(length: 3, vsync: this); }
  @override void dispose()   { _tc.dispose(); super.dispose(); }
  List<Map<String,dynamic>> _f(String s) => _fakeBookings.where((b) => b['status']==s).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tc,
          indicatorColor: kGold, labelColor: kGold, unselectedLabelColor: kTextS,
          tabs: const [Tab(text:'Active'), Tab(text:'Upcoming'), Tab(text:'Past')],
        ),
      ),
      body: TabBarView(controller: _tc, children: [
        _BList(items: _f('active')),
        _BList(items: _f('upcoming')),
        _BList(items: _f('completed')),
      ]),
    );
  }
}

class _BList extends StatelessWidget {
  final List<Map<String,dynamic>> items;
  const _BList({required this.items});
  @override Widget build(BuildContext context) {
    if (items.isEmpty) return Center(child: Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      const Icon(Icons.receipt_long_rounded,color:kTextS,size:56),
      const SizedBox(height:14),
      const Text('No bookings here',style:TextStyle(color:kTextS,fontSize:16)),
    ]));
    return ListView.builder(padding:const EdgeInsets.all(16),itemCount:items.length,
      itemBuilder:(_,i)=>_BCard(b:items[i]));
  }
}

class _BCard extends StatelessWidget {
  final Map<String,dynamic> b;
  const _BCard({required this.b});
  Color get _sc { switch(b['status']){ case 'active':return kSuccess; case 'upcoming':return kWarn; default:return kTextS; } }
  String get _sl { switch(b['status']){ case 'active':return '● Active'; case 'upcoming':return '● Upcoming'; default:return '✓ Completed'; } }
  @override Widget build(BuildContext context) => Container(
    margin:const EdgeInsets.only(bottom:14),
    decoration:BoxDecoration(color:kSurf,borderRadius:BorderRadius.circular(16)),
    child:Column(children:[
      Padding(padding:const EdgeInsets.all(14),child:Row(children:[
        Container(width:50,height:50,decoration:BoxDecoration(color:Color(b['color'] as int),borderRadius:BorderRadius.circular(10)),
          child:const Icon(Icons.directions_car_rounded,color:Colors.white,size:26)),
        const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(b['car'] as String,style:const TextStyle(color:kText,fontWeight:FontWeight.w700,fontSize:15)),
          Text(b['cat'] as String,style:const TextStyle(color:kTextS,fontSize:12)),
        ])),
        Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
          decoration:BoxDecoration(color:_sc.withOpacity(0.12),borderRadius:BorderRadius.circular(20)),
          child:Text(_sl,style:TextStyle(color:_sc,fontSize:11,fontWeight:FontWeight.w700))),
      ])),
      const Divider(color:kSurf2,height:1),
      Padding(padding:const EdgeInsets.symmetric(horizontal:14,vertical:12),
        child:Row(children:[
          _IC(label:'Pick-up',value:b['from'] as String),
          const Icon(Icons.arrow_forward_rounded,color:kTextS,size:14),
          _IC(label:'Return',value:b['to'] as String),
          const Spacer(),
          _IC(label:'Days',value:'${b['days']}',align:CrossAxisAlignment.end),
        ])),
      const Divider(color:kSurf2,height:1),
      Padding(padding:const EdgeInsets.fromLTRB(14,10,14,14),
        child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('Ref: ${b['ref']}',style:const TextStyle(color:kTextS,fontSize:11)),
            Text('\$${b['total']} total',style:const TextStyle(color:kGold,fontWeight:FontWeight.w800,fontSize:15)),
          ]),
          if(b['status']=='active') ElevatedButton.icon(
            onPressed:(){},icon:const Icon(Icons.qr_code_rounded,size:14),label:const Text('QR Pass'),
            style:ElevatedButton.styleFrom(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),textStyle:const TextStyle(fontSize:12))),
          if(b['status']=='upcoming') OutlinedButton(onPressed:(){},
            style:OutlinedButton.styleFrom(side:const BorderSide(color:kError),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),padding:const EdgeInsets.symmetric(horizontal:12,vertical:8)),
            child:const Text('Cancel',style:TextStyle(color:kError,fontSize:12))),
          if(b['status']=='completed') OutlinedButton(onPressed:(){},
            style:OutlinedButton.styleFrom(side:const BorderSide(color:kGold),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),padding:const EdgeInsets.symmetric(horizontal:12,vertical:8)),
            child:const Text('Rebook',style:TextStyle(color:kGold,fontSize:12))),
        ])),
    ]),
  );
}

class _IC extends StatelessWidget {
  final String label,value; final CrossAxisAlignment align;
  const _IC({required this.label,required this.value,this.align=CrossAxisAlignment.start});
  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:align,children:[
    Text(label,style:const TextStyle(color:kTextS,fontSize:10)),
    const SizedBox(height:2),
    Text(value,style:const TextStyle(color:kText,fontWeight:FontWeight.w600,fontSize:12)),
  ]);
}
