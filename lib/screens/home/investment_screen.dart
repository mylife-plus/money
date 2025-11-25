import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/custom_app_bar.dart';
import 'package:moneyapp/widgets/common/custom_toggle_switch.dart';
import 'package:moneyapp/widgets/investments/portfolio_section.dart';
import 'package:moneyapp/widgets/trades/trades_section.dart';

/// Investment Screen
/// Main investment screen of the app
class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _lastScrollOffset = 0;
  bool _isAppBarVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final currentScrollOffset = _scrollController.offset;
    final scrollDelta = currentScrollOffset - _lastScrollOffset;

    // Scrolling down
    if (scrollDelta > 0 && _isAppBarVisible && currentScrollOffset > 50) {
      setState(() {
        _isAppBarVisible = false;
      });
      _animationController.reverse();
    }
    // Scrolling up
    else if (scrollDelta < 0 && !_isAppBarVisible) {
      setState(() {
        _isAppBarVisible = true;
      });
      _animationController.forward();
    }

    _lastScrollOffset = currentScrollOffset;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InvestmentController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizeTransition(
              sizeFactor: _animation,
              child: FadeTransition(
                opacity: _animation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomAppBar(
                      title: 'Investments',
                      leadingIconPath: AppIcons.investment,
                      actionIconPath: AppIcons.transaction,
                      onActionIconTap: () {
                        Get.offNamed(AppRoutes.home.path);
                      },
                    ),
                    27.verticalSpace,
                    Obx(
                      () => CustomToggleSwitch(
                        option1IconPath: AppIcons.chartSquare,
                        option1Text: 'Portfolio',
                        option2IconPath: AppIcons.bitcoinConvert,
                        option2Text: 'Trades',
                        selectedOption: controller.selectedToggleOption.value,
                        onOption1Tap: controller.selectPortfolio,
                        onOption2Tap: controller.selectTrades,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Obx(() {
                  return controller.isPortfolioSelected
                      ? PortfolioSection(
                          isPortfolioSelected:
                              controller.isPortfolioSelected,
                        )
                      : TradesSection();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
