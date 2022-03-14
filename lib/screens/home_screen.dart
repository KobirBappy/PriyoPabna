import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../common/assets.dart';
import '../common/colors.dart';
import '../widgets/all_blood_requests.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  static const route = 'home';
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-3940256099942544/6300978111',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  @override
  void initState() {
    super.initState();
    myBanner.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(),
    appBar: AppBar(
      title: Text('Emargency Request!'),
      bottom: PreferredSize(
          child: Container(
            color: Colors.transparent,
            height: 50.0,
            child: AdWidget(ad: myBanner,),
          ),
          preferredSize: Size.fromHeight(40.0)),
    ),

      body:
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              IconAssets.bloodBagHand,
                              height: 80,
                              width: 80,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Donate Blood,\nSave Lives',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      .copyWith(color: MainColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverAppBar(
                  title: Text(
                    'Current Requests',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(color: MainColors.primary),
                  ),
                  primary: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  automaticallyImplyLeading: false,
                ),
                const AllBloodRequests(),
              ],
            ),
      ),
    );
  }
}
