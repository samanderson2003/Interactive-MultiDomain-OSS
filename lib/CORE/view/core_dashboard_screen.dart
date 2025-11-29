import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../controller/core_controller.dart';
import '../model/core_element_model.dart';

class CoreDashboardScreen extends StatefulWidget {
  const CoreDashboardScreen({super.key});

  @override
  State<CoreDashboardScreen> createState() => _CoreDashboardScreenState();
}

class _CoreDashboardScreenState extends State<CoreDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoreController>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildNetworkTopologyPreview(context),
                    const SizedBox(height: 16),
                    _buildKPICards(context),
                    const SizedBox(height: 16),
                    _buildServiceHealthGrid(context),
                    const SizedBox(height: 16),
                    _buildQuickAccessGrid(context),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
          _buildFloatingBotAnimation(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF131823),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'CORE Network',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0ea5e9).withOpacity(0.1),
                const Color(0xFF131823),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/core-profile'),
          tooltip: 'Profile',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNetworkTopologyPreview(BuildContext context) {
    return Consumer<CoreController>(
      builder: (context, controller, _) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF131823),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0ea5e9).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Network Topology',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/core-topology'),
                      icon: const Icon(Icons.open_in_full, size: 16),
                      label: const Text('View Full'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0ea5e9),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildMiniTopology(controller)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniTopology(CoreController controller) {
    final elements = controller.coreElements;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTopologyNode(
              'HLR',
              Icons.storage,
              elements.where((e) => e.type == CoreElementType.hlr).length,
            ),
            _buildTopologyConnection(),
            _buildTopologyNode(
              'MME',
              Icons.router,
              elements.where((e) => e.type == CoreElementType.mme).length,
            ),
            _buildTopologyConnection(),
            _buildTopologyNode(
              'SGW',
              Icons.network_cell,
              elements.where((e) => e.type == CoreElementType.sgw).length,
            ),
            _buildTopologyConnection(),
            _buildTopologyNode(
              'PGW',
              Icons.cloud,
              elements.where((e) => e.type == CoreElementType.pgw).length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopologyNode(String label, IconData icon, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF0ea5e9).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF0ea5e9), width: 2),
          ),
          child: Icon(icon, color: const Color(0xFF0ea5e9), size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          '$count',
          style: GoogleFonts.poppins(fontSize: 9, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildTopologyConnection() {
    return Container(
      width: 30,
      height: 2,
      color: const Color(0xFF0ea5e9).withOpacity(0.5),
    );
  }

  Widget _buildKPICards(BuildContext context) {
    return Consumer<CoreController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Performance Indicators',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 140, child: _buildAutoScrollingKPIs(controller)),
          ],
        );
      },
    );
  }

  Widget _buildAutoScrollingKPIs(CoreController controller) {
    final kpiItems = [
      _buildKPICard(
        'Attach Success Rate',
        '${(controller.kpis.attachSuccessRate * 100).toStringAsFixed(1)}%',
        Icons.link,
        Colors.green,
        controller.kpis.attachSuccessRate > 0.95,
      ),
      _buildKPICard(
        'Detach Rate',
        '${controller.kpis.detachRate.toStringAsFixed(1)}/s',
        Icons.link_off,
        Colors.orange,
        controller.kpis.detachRate < 50,
      ),
      _buildKPICard(
        'Average Latency',
        '${controller.kpis.averageLatency.toStringAsFixed(0)}ms',
        Icons.speed,
        Colors.blue,
        controller.kpis.averageLatency < 100,
      ),
      _buildKPICard(
        'Total Throughput',
        '${controller.kpis.totalThroughput.toStringAsFixed(1)} Gbps',
        Icons.trending_up,
        Colors.purple,
        true,
      ),
    ];

    return _AutoScrollView(
      items: kpiItems,
      scrollDirection: ScrollDirection.leftToRight,
      itemWidth: 200,
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isHealthy,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHealthy
              ? color.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Icon(
                isHealthy ? Icons.check_circle : Icons.warning,
                color: isHealthy ? Colors.green : Colors.red,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHealthGrid(BuildContext context) {
    return Consumer<CoreController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Health',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/core-services'),
                  child: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0ea5e9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: _buildAutoScrollingServices(controller),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAutoScrollingServices(CoreController controller) {
    final serviceItems = controller.serviceHealthList.map((service) {
      return _buildServiceHealthCard(
        service.name,
        service.status,
        service.uptime,
      );
    }).toList();

    // If no items, show message
    if (serviceItems.isEmpty) {
      return Center(
        child: Text(
          'No services available',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
      );
    }

    return _AutoScrollView(
      items: serviceItems,
      scrollDirection: ScrollDirection.rightToLeft,
      itemWidth: 200,
    );
  }

  Widget _buildServiceHealthCard(
    String serviceName,
    String status,
    double uptime,
  ) {
    final isHealthy = status == 'Operational';
    final color = isHealthy
        ? Colors.green
        : (status == 'Degraded' ? Colors.orange : Colors.red);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  serviceName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${uptime.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildQuickAccessCard(
              'CORE Elements',
              'assets/server storage.json',
              '/core-elements-list',
            ),
            _buildQuickAccessCard(
              'Analytics',
              'assets/Data Analytics.json',
              '/core-analytics',
            ),
            _buildQuickAccessCard(
              'Network Map',
              'assets/Network (1).json',
              '/core-topology',
            ),
            _buildQuickAccessCard(
              'Services',
              'assets/Services.json',
              '/core-services',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(String title, String lottieAsset, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0ea5e9).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Lottie.asset(lottieAsset, fit: BoxFit.contain)),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBotAnimation(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/core-bot');
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Lottie.asset(
            'assets/loading bot.json',
            width: 70,
            height: 70,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

enum ScrollDirection { leftToRight, rightToLeft }

class _AutoScrollView extends StatefulWidget {
  final List<Widget> items;
  final ScrollDirection scrollDirection;
  final double itemWidth;

  const _AutoScrollView({
    required this.items,
    required this.scrollDirection,
    required this.itemWidth,
  });

  @override
  State<_AutoScrollView> createState() => _AutoScrollViewState();
}

class _AutoScrollViewState extends State<_AutoScrollView> {
  late ScrollController _scrollController;
  late List<Widget> _infiniteItems;
  double _currentOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Duplicate items many times for truly infinite effect
    _infiniteItems = [
      ...widget.items,
      ...widget.items,
      ...widget.items,
      ...widget.items,
      ...widget.items,
      ...widget.items,
    ];

    // Only start auto-scroll if we have items
    if (widget.items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final singleSetWidth = widget.itemWidth * widget.items.length;
          if (widget.scrollDirection == ScrollDirection.rightToLeft) {
            // Start from the middle for right to left
            _currentOffset = singleSetWidth * 3;
            _scrollController.jumpTo(_currentOffset);
          } else {
            // Start from the middle for left to right
            _currentOffset = singleSetWidth * 3;
            _scrollController.jumpTo(_currentOffset);
          }
          _startAutoScroll();
        }
      });
    }
  }

  void _startAutoScroll() {
    Future.doWhile(() async {
      if (!mounted) return false;

      await Future.delayed(const Duration(milliseconds: 16)); // 60fps

      if (_scrollController.hasClients && mounted) {
        final singleSetWidth = widget.itemWidth * widget.items.length;

        if (widget.scrollDirection == ScrollDirection.leftToRight) {
          _currentOffset += 0.8;

          // Seamlessly reset when reaching the 5th set
          if (_currentOffset >= singleSetWidth * 4.5) {
            final overflow = _currentOffset - (singleSetWidth * 4.5);
            _currentOffset = (singleSetWidth * 2.5) + overflow;
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_currentOffset);
            }
          } else {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_currentOffset);
            }
          }
        } else {
          _currentOffset -= 0.8;

          // Seamlessly reset when reaching the 1st set
          if (_currentOffset <= singleSetWidth * 1.5) {
            final overflow = (singleSetWidth * 1.5) - _currentOffset;
            _currentOffset = (singleSetWidth * 3.5) - overflow;
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_currentOffset);
            }
          } else {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_currentOffset);
            }
          }
        }
      }

      return mounted;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_infiniteItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _infiniteItems.length,
      itemBuilder: (context, index) {
        return Container(
          width: widget.itemWidth,
          margin: const EdgeInsets.only(right: 12),
          child: _infiniteItems[index],
        );
      },
    );
  }
}
