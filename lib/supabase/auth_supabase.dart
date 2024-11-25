import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../upload_video.dart';
import 'login_page_supbase.dart';

class AuthSupabase extends StatelessWidget {
  const AuthSupabase({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: Supabase.instance.client.auth.onAuthStateChange, builder: (ctx,snapshot){
      if(snapshot.connectionState == ConnectionState.waiting){
        return Center(child: CircularProgressIndicator(),);
      }else if(snapshot.data == null){
        return LoginPageSupbase();
      }
      return VideoUploader();
     
    });
  }
}