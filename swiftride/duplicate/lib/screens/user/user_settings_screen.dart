// lib/screens/user/user_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/services/auth_service.dart';
import 'package:swiftride/utils/constants.dart' show
    kNavy, kGold, kSurf, kSurf2, kText, kTextS, kError, kSuccess, AppColors;

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});
  @override State<UserSettingsScreen> createState() => _State();
}
class _State extends State<UserSettingsScreen> {
  bool _nb=true,_nm=true,_np=false,_dark=true,_loc=true,_bio=false;
  String _cur='USD',_lang='English';

  void _logout()=>showDialog(context:context,builder:(_)=>AlertDialog(
    backgroundColor:kSurf,
    title:const Text('Logout',style:TextStyle(color:kText)),
    content:const Text('Are you sure you want to log out?',style:TextStyle(color:kTextS)),
    actions:[
      TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel',style:TextStyle(color:kTextS))),
      TextButton(onPressed:(){AuthService.logout();Navigator.pushNamedAndRemoveUntil(context,'/home',(_)=>false);},
        child:const Text('Logout',style:TextStyle(color:kError,fontWeight:FontWeight.w700))),
    ],
  ));

  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:kNavy,
    appBar:AppBar(title:const Text('Settings')),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      Container(margin:const EdgeInsets.only(bottom:20),padding:const EdgeInsets.all(14),
        decoration:BoxDecoration(color:kSurf,borderRadius:BorderRadius.circular(14)),
        child:Row(children:[
          CircleAvatar(radius:24,backgroundColor:kGold,
            child:Text(AuthService.userName.split(' ').map((e)=>e[0]).take(2).join(),
              style:const TextStyle(color:Colors.black,fontWeight:FontWeight.w800))),
          const SizedBox(width:14),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(AuthService.userName,style:const TextStyle(color:kText,fontWeight:FontWeight.w700)),
            Text(AuthService.userEmail,style:const TextStyle(color:kTextS,fontSize:12)),
          ])),
          TextButton(onPressed:()=>Navigator.pushNamed(context,'/user/profile'),
            child:const Text('Edit',style:TextStyle(color:kGold))),
        ])),
      _Grp(title:'Notifications',children:[
        _SW(icon:Icons.receipt_long_rounded,label:'Booking Updates',value:_nb,onChanged:(v)=>setState(()=>_nb=v)),
        _SW(icon:Icons.message_rounded,label:'New Messages',value:_nm,onChanged:(v)=>setState(()=>_nm=v)),
        _SW(icon:Icons.local_offer_rounded,label:'Promotions',value:_np,onChanged:(v)=>setState(()=>_np=v)),
      ]),
      const SizedBox(height:16),
      _Grp(title:'Preferences',children:[
        _SW(icon:Icons.dark_mode_rounded,label:'Dark Mode',value:_dark,onChanged:(v)=>setState(()=>_dark=v)),
        _SW(icon:Icons.location_on_rounded,label:'Share Location',value:_loc,onChanged:(v)=>setState(()=>_loc=v)),
        _SW(icon:Icons.fingerprint_rounded,label:'Biometric Login',value:_bio,onChanged:(v)=>setState(()=>_bio=v)),
        _DD(icon:Icons.attach_money_rounded,label:'Currency',value:_cur,options:const['USD','EUR','GBP','RWF'],onChanged:(v)=>setState(()=>_cur=v!)),
        _DD(icon:Icons.language_rounded,label:'Language',value:_lang,options:const['English','French','Kinyarwanda','Swahili'],onChanged:(v)=>setState(()=>_lang=v!)),
      ]),
      const SizedBox(height:16),
      _Grp(title:'Security',children:[
        _NV(icon:Icons.lock_outline_rounded,label:'Change Password',onTap:(){}),
        _NV(icon:Icons.security_rounded,label:'Two-Factor Auth',onTap:(){}),
      ]),
      const SizedBox(height:16),
      _Grp(title:'Support',children:[
        _NV(icon:Icons.help_outline_rounded,label:'Help Center',onTap:(){}),
        _NV(icon:Icons.feedback_outlined,label:'Send Feedback',onTap:(){}),
        _NV(icon:Icons.policy_outlined,label:'Privacy Policy',onTap:(){}),
        _NV(icon:Icons.description_outlined,label:'Terms of Service',onTap:(){}),
      ]),
      const SizedBox(height:20),
      const Center(child:Text('SwiftRide v1.0.0 (Demo)',style:TextStyle(color:kTextS,fontSize:11))),
      const SizedBox(height:16),
      ElevatedButton.icon(
        onPressed:_logout,
        icon:const Icon(Icons.logout_rounded),label:const Text('Logout'),
        style:ElevatedButton.styleFrom(
          backgroundColor:kError.withOpacity(0.15),foregroundColor:kError,
          side:const BorderSide(color:kError,width:1.5),
          padding:const EdgeInsets.symmetric(vertical:14)),
      ),
      const SizedBox(height:30),
    ]),
  );
}
class _Grp extends StatelessWidget {
  final String title; final List<Widget> children;
  const _Grp({required this.title,required this.children});
  @override Widget build(BuildContext c)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(title.toUpperCase(),style:const TextStyle(color:kTextS,fontSize:11,fontWeight:FontWeight.w700,letterSpacing:1.2)),
    const SizedBox(height:8),
    Container(decoration:BoxDecoration(color:kSurf,borderRadius:BorderRadius.circular(14)),child:Column(children:children)),
  ]);
}
class _SW extends StatelessWidget {
  final IconData icon; final String label; final bool value; final ValueChanged<bool> onChanged;
  const _SW({required this.icon,required this.label,required this.value,required this.onChanged});
  @override Widget build(BuildContext c)=>ListTile(
    leading:Container(width:36,height:36,decoration:BoxDecoration(color:kSurf2,borderRadius:BorderRadius.circular(10)),child:Icon(icon,color:kTextS,size:18)),
    title:Text(label,style:const TextStyle(color:kText,fontSize:13)),
    trailing:Switch(value:value,onChanged:onChanged,activeColor:kGold),dense:true);
}
class _NV extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _NV({required this.icon,required this.label,required this.onTap});
  @override Widget build(BuildContext c)=>ListTile(
    leading:Container(width:36,height:36,decoration:BoxDecoration(color:kSurf2,borderRadius:BorderRadius.circular(10)),child:Icon(icon,color:kTextS,size:18)),
    title:Text(label,style:const TextStyle(color:kText,fontSize:13)),
    trailing:const Icon(Icons.arrow_forward_ios_rounded,color:kTextS,size:14),
    onTap:onTap,dense:true);
}
class _DD extends StatelessWidget {
  final IconData icon; final String label,value; final List<String> options; final ValueChanged<String?> onChanged;
  const _DD({required this.icon,required this.label,required this.value,required this.options,required this.onChanged});
  @override Widget build(BuildContext c)=>ListTile(
    leading:Container(width:36,height:36,decoration:BoxDecoration(color:kSurf2,borderRadius:BorderRadius.circular(10)),child:Icon(icon,color:kTextS,size:18)),
    title:Text(label,style:const TextStyle(color:kText,fontSize:13)),
    trailing:DropdownButton<String>(value:value,
      items:options.map((o)=>DropdownMenuItem(value:o,child:Text(o,style:const TextStyle(color:kText,fontSize:13)))).toList(),
      onChanged:onChanged,dropdownColor:kSurf,underline:const SizedBox(),style:const TextStyle(color:kGold)),
    dense:true);
}
