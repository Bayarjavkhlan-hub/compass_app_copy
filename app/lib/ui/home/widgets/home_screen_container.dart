import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/booking/booking_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../auth/logout/view_models/logout_viewmodel.dart';
import '../view_models/home_viewmodel.dart';
import 'home_screen.dart';

class HomeScreenContainer extends StatefulWidget {
  const HomeScreenContainer({super.key, required this.logoutViewModel});

  final LogoutViewModel logoutViewModel;

  @override
  State<HomeScreenContainer> createState() => _HomeScreenContainerState();
}

class _HomeScreenContainerState extends State<HomeScreenContainer> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = HomeViewModel(
      bookingRepository: context.read<BookingRepository>(),
      userRepository: context.read<UserRepository>(),
    );
  }

  @override
  void didUpdateWidget(covariant HomeScreenContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The router rebuilds this route (with a new LogoutViewModel) when
    // navigating back to home, e.g. after creating a booking. The State and
    // its view model survive that, so refresh the bookings list explicitly.
    if (oldWidget.logoutViewModel != widget.logoutViewModel) {
      _viewModel.load.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      viewModel: _viewModel,
      logoutViewModel: widget.logoutViewModel,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
