import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/screens/investments/new_portfolio_change_screen.dart';
import 'package:moneyapp/widgets/common/custom_app_bar.dart';
import 'package:moneyapp/widgets/common/custom_toggle_switch.dart';
import 'package:moneyapp/widgets/common/selection_app_bar.dart';
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
  bool _showScrollToTop = false;
  static const double _scrollThreshold = 5.0;

  // Selection state — owned here so SelectionAppBar stays outside the scroll view
  int _selectionCount = 0;
  VoidCallback? _cancelSelection;
  VoidCallback? _deleteSelection;

  bool get _isSelectionMode => _selectionCount > 0;

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

    // Clear selection state whenever the tab changes (portfolio ↔ trades).
    final controller = Get.find<InvestmentController>();
    ever(controller.selectedToggleOption, (_) {
      if (_selectionCount > 0) {
        setState(() {
          _selectionCount = 0;
          _cancelSelection = null;
          _deleteSelection = null;
        });
      }
    });
  }

  void _onScroll() {
    // Don't hide app bar while in selection mode
    if (_isSelectionMode) return;

    final currentScrollOffset = _scrollController.offset;
    final scrollDelta = currentScrollOffset - _lastScrollOffset;

    if (currentScrollOffset > 200 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (currentScrollOffset <= 200 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }

    if (scrollDelta.abs() < _scrollThreshold) return;

    if (scrollDelta > 0 && _isAppBarVisible && currentScrollOffset > 50) {
      _isAppBarVisible = false;
      _animationController.reverse();
      setState(() {});
    } else if (scrollDelta < 0 && !_isAppBarVisible) {
      _isAppBarVisible = true;
      _animationController.forward();
      setState(() {});
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
      floatingActionButton: _isSelectionMode
          ? null
          : InkWell(
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
                  child: Image.asset(
                    AppIcons.roundedPlus,
                    height: 27.r,
                    width: 27.r,
                  ),
                ),
              ),
            ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                // Top bar: SelectionAppBar (screen level) OR animated CustomAppBar
                if (_isSelectionMode)
                  SelectionAppBar(
                    selectedCount: _selectionCount,
                    onCancel: _cancelSelection ?? () {},
                    onDelete: _deleteSelection ?? () {},
                  )
                else
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
                        Offstage(
                          offstage: _isSelectionMode,
                          child: Obx(
                            () => CustomToggleSwitch(
                              iconColorShouldEffect: true,
                              option1IconPath: AppIcons.chartSquare,
                              option1Text: 'Portfolio',
                              option2IconPath: AppIcons.bitcoinConvert,
                              option2Text: 'Trades',
                              selectedOption:
                                  controller.selectedToggleOption.value,
                              onOption1Tap: controller.selectPortfolio,
                              onOption2Tap: controller.selectTrades,
                            ),
                          ),
                        ),
                        Obx(() {
                          if (controller.isPortfolioSelected) {
                            return PortfolioSection(isPortfolioSelected: true);
                          }
                          return TradesSection(
                            onSelectionChanged:
                                (isSelection, count, onCancel, onDelete) {
                                  setState(() {
                                    _selectionCount = count;
                                    _cancelSelection = onCancel;
                                    _deleteSelection = onDelete;
                                  });
                                },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_showScrollToTop && !_isSelectionMode)
              Positioned(
                bottom: 40.h,
                right: 30.w,
                child: InkWell(
                  onTap: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    height: 30.r,
                    width: 30.r,
                    decoration: BoxDecoration(
                      color: const Color(0xffFFCC00),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(2.r),
                        child: Image.asset(
                          AppIcons.arrowUp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
