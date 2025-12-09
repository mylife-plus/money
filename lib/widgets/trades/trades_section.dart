import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/trades/received_trade_item.dart';
import 'package:moneyapp/widgets/trades/trade_item_pair.dart';

class TradesSection extends StatelessWidget {
  const TradesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        40.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.0.w),
          child: Row(
            children: [
              InkWell(
                child: Image.asset(AppIcons.sort, height: 24.r, width: 24.r),
              ),
              40.horizontalSpace,
              InkWell(
                child: Image.asset(AppIcons.filter, height: 24.r, width: 24.r),
              ),
              40.horizontalSpace,
              InkWell(
                child: Image.asset(AppIcons.search, height: 24.r, width: 24.r),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.newPortfolioChange.path);
                },
                child: Image.asset(AppIcons.plus, height: 21.r, width: 21.r),
              ),
            ],
          ),
        ),
        16.verticalSpace,
        Padding(
          padding: EdgeInsets.only(left: 13.0.w),
          child: CustomText('2024', color: Color(0xff707070), size: 20.sp),
        ),
        11.verticalSpace,
        Padding(
          padding: EdgeInsets.only(left: 14.0.w),
          child: CustomText('12. Dec.'),
        ),
        9.verticalSpace,
        Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          child: TradeItemPair(
            soldAmount: '1',
            soldSymbol: 'BTC',
            soldPrice: '120.000',
            soldPriceSymbol: 'USD',
            soldTotal: '120,000',
            soldTotalSymbol: 'USD',
            boughtAmount: '10',
            boughtSymbol: 'ETH',
            boughtPrice: '10.100',
            boughtPriceSymbol: 'USD',
            boughtTotal: '120,000',
            boughtTotalSymbol: 'USD',
          ),
        ),
        22.verticalSpace,
        Padding(
          padding: EdgeInsets.only(left: 14.0.w),
          child: Row(
            children: [Expanded(flex: 84, child: CustomText('1. Dec.'))],
          ),
        ),
        11.verticalSpace,
        Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            children: [
              TradeItemPair(
                soldAmount: '30,000',
                soldSymbol: 'EUR',
                soldPrice: '120.000',
                soldPriceSymbol: 'USD',
                soldTotal: '10.100',
                soldTotalSymbol: 'USD',
                boughtAmount: '1 🏠',
                boughtSymbol: '',
                boughtPrice: '10.100',
                boughtPriceSymbol: 'USD',
                boughtTotal: '10.100',
                boughtTotalSymbol: 'USD',
              ),
              10.verticalSpace,
              TradeItemPair(
                soldAmount: '30,000',
                soldSymbol: 'EUR',
                soldPrice: '120.000',
                soldPriceSymbol: 'USD',
                soldTotal: '10.100',
                soldTotalSymbol: 'USD',
                boughtAmount: '1 🏠',
                boughtSymbol: '',
                boughtPrice: '10.100',
                boughtPriceSymbol: 'USD',
                boughtTotal: '10.100',
                boughtTotalSymbol: 'USD',
              ),
              10.verticalSpace,
              TradeItemPair(
                soldAmount: '30,000',
                soldSymbol: 'EUR',
                soldPrice: '120.000',
                soldPriceSymbol: 'USD',
                soldTotal: '10.100',
                soldTotalSymbol: 'USD',
                boughtAmount: '1 🏠',
                boughtSymbol: '',
                boughtPrice: '10.100',
                boughtPriceSymbol: 'USD',
                boughtTotal: '10.100',
                boughtTotalSymbol: 'USD',
              ),
              10.verticalSpace,
              TradeItemPair(
                soldAmount: '30,000',
                soldSymbol: 'EUR',
                soldPrice: '120.000',
                soldPriceSymbol: 'USD',
                soldTotal: '10.100',
                soldTotalSymbol: 'USD',
                boughtAmount: '1 🏠',
                boughtSymbol: '',
                boughtPrice: '10.100',
                boughtPriceSymbol: 'USD',
                boughtTotal: '10.100',
                boughtTotalSymbol: 'USD',
              ),
              10.verticalSpace,
              TradeItemPair(
                soldAmount: '30,000',
                soldSymbol: 'EUR',
                soldPrice: '120.000',
                soldPriceSymbol: 'USD',
                soldTotal: '10.100',
                soldTotalSymbol: 'USD',
                boughtAmount: '1 🏠',
                boughtSymbol: '',
                boughtPrice: '10.100',
                boughtPriceSymbol: 'USD',
                boughtTotal: '10.100',
                boughtTotalSymbol: 'USD',
              ),
              10.verticalSpace,
              TradeItemPair(
                soldAmount: '30,000',
                soldSymbol: 'EUR',
                soldPrice: '120.000',
                soldPriceSymbol: 'USD',
                soldTotal: '10.100',
                soldTotalSymbol: 'USD',
                boughtAmount: '1 🏠',
                boughtSymbol: '',
                boughtPrice: '10.100',
                boughtPriceSymbol: 'USD',
                boughtTotal: '10.100',
                boughtTotalSymbol: 'USD',
              ),
              10.verticalSpace,
              TradeItemPair(
                soldAmount: '30,000',
                soldSymbol: 'EUR',
                soldPrice: '120.000',
                soldPriceSymbol: 'USD',
                soldTotal: '120,000',
                soldTotalSymbol: 'USD',
                boughtAmount: '1 🚙',
                boughtSymbol: '',
                boughtPrice: '10.100',
                boughtPriceSymbol: 'USD',
                boughtTotal: '120,000',
                boughtTotalSymbol: 'USD',
              ),
              10.verticalSpace,
              ReceivedTradeItem(
                title: 'Chromia Staking Rewards',
                amount: '120',
                symbol: 'CHR',
                price: '0.72',
                priceSymbol: 'USD',
                total: '78.5',
                totalSymbol: 'USD',
              ),
            ],
          ),
        ),

        9.verticalSpace,
      ],
    );
  }
}
