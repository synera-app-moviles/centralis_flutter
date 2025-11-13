import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'shared/theme/theme.dart';
import 'app/routes/app_router.dart';
import 'app/routes/route_names.dart';
import 'core/di/service_locator.dart';
import 'iam/presentation/bloc/auth_bloc.dart';
import 'profile/presentation/bloc/profile_bloc.dart';
import 'events/presentation/bloc/event_bloc.dart';
import 'chat/presentation/bloc/chat_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await initializeDependencies();
  
  runApp(const CentralisApp());
}

class CentralisApp extends StatelessWidget {
  const CentralisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => sl<ProfileBloc>(),
        ),
        BlocProvider<EventBloc>(create: (context) => sl<EventBloc>()),
        BlocProvider<ChatBloc>(
          create: (context) => sl<ChatBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Centralis',
        debugShowCheckedModeBanner: false,
        
        // Use our custom theme (always dark)
        theme: CentralisTheme.darkTheme,
        
        // Navigation setup using onGenerateRoute
        initialRoute: RouteNames.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
