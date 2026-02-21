import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/screens/investments/new_portfolio_change_screen.dart';
import 'package:moneyapp/widgets/common/custom_app_bar.dart';
import 'package:moneyapp/widgets/common/custom_toggle_switch.dart';
import 'package:moneyapp/widgets/common/slide_from_top_route.dart';
import 'package:moneyapp/widgets/investments/portfolio_section.dart';
import 'package:moneyapp/widgets/trades/trades_section.dart';

/// Investment Screen
/// Main investment screen of the app
class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _lastScrollOffset = 0;
  bool _isAppBarVisible = true;
  bool _isSelectionMode = false;
  static const double _scrollThreshold =
      5.0; // Minimum scroll distance to trigger

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

    // Only process if scroll delta exceeds threshold
    if (scrollDelta.abs() < _scrollThreshold) return;

    // Scrolling down - hide app bar
    if (scrollDelta > 0 && _isAppBarVisible && currentScrollOffset > 50) {
      _isAppBarVisible = false;
      _animationController.reverse();
      setState(() {}); // Minimal setState after animation starts
    }
    // Scrolling up - show app bar
    else if (scrollDelta < 0 && !_isAppBarVisible) {
      _isAppBarVisible = true;
      _animationController.forward();
      setState(() {}); // Minimal setState after animation starts
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(
            context,
            SlideFromTopRoute(page: const NewPortfolioChangeScreen()),
          );
        },
        child: Container(
          height: 51.r,
          width: 51.r,
          decoration: BoxDecoration(
            color: const Color(0xffFFCC00),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Center(
            child: Image.asset(AppIcons.roundedPlus, height: 27.r, width: 27.r),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isSelectionMode)
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
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.home.path,
                          );
                        },
                        onSettingsReturn: () {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    if (!_isSelectionMode) ...[
                      // 20.verticalSpace,
                      Obx(
                        () => CustomToggleSwitch(
                          iconColorShouldEffect: true,
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
                    Obx(() {
                      return IndexedStack(
                        index: controller.isPortfolioSelected ? 0 : 1,
                        sizing: StackFit.loose,
                        children: [
                          PortfolioSection(
                            isPortfolioSelected: controller.isPortfolioSelected,
                          ),
                          TradesSection(
                            onSelectionModeChanged: (isSelectionMode) {
                              setState(() {
                                _isSelectionMode = isSelectionMode;
                              });
                            },
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
