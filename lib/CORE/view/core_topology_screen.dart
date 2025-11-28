import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controller/core_controller.dart';
import '../model/core_element_model.dart';
import '../model/topology_node_model.dart';

class CoreTopologyScreen extends StatefulWidget {
  const CoreTopologyScreen({super.key});

  @override
  State<CoreTopologyScreen> createState() => _CoreTopologyScreenState();
}

class _CoreTopologyScreenState extends State<CoreTopologyScreen> {
  TopologyNodeModel? _selectedNode;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CoreController>();
      if (controller.topologyNodes.isEmpty) {
        controller.loadDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'Network Topology',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            onPressed: () {
              _transformationController.value = Matrix4.identity()..scale(2.0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            onPressed: () {
              _transformationController.value = Matrix4.identity();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<CoreController>().refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CoreController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0ea5e9)),
            );
          }

          return Row(
            children: [
              Expanded(flex: 3, child: _buildTopologyCanvas(controller)),
              if (_selectedNode != null)
                Container(
                  width: 300,
                  color: const Color(0xFF131823),
                  child: _buildNodeDetails(_selectedNode!),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopologyCanvas(CoreController controller) {
    return Container(
      color: const Color(0xFF0a0e1a),
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Container(
            width: 900,
            height: 600,
            decoration: BoxDecoration(
              color: const Color(0xFF131823),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF0ea5e9).withOpacity(0.3),
              ),
            ),
            child: CustomPaint(
              painter: TopologyPainter(
                nodes: controller.topologyNodes,
                selectedNode: _selectedNode,
              ),
              child: Stack(
                children: controller.topologyNodes.map((node) {
                  return Positioned(
                    left: node.position.dx,
                    top: node.position.dy,
                    child: _buildNode(node),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNode(TopologyNodeModel node) {
    final isSelected = _selectedNode?.id == node.id;
    final icon = _getIconForType(node.type);
    final color = isSelected ? const Color(0xFF0ea5e9) : Colors.white;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNode = node;
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF0ea5e9).withOpacity(isSelected ? 0.3 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: isSelected ? 3 : 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0ea5e9).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              node.name,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeDetails(TopologyNodeModel node) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Node Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedNode = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Name', node.name),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Type',
            node.type.toString().split('.').last.toUpperCase(),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('ID', node.id),
          const SizedBox(height: 24),
          Text(
            'Connections',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...node.connections.map((connId) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0a0e1a),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF0ea5e9).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  connId,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(CoreElementType type) {
    switch (type) {
      case CoreElementType.hlr:
        return Icons.storage;
      case CoreElementType.epc:
        return Icons.hub;
      case CoreElementType.mme:
        return Icons.router;
      case CoreElementType.sgw:
        return Icons.network_cell;
      case CoreElementType.pgw:
        return Icons.cloud;
      case CoreElementType.hss:
        return Icons.dns;
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}

class TopologyPainter extends CustomPainter {
  final List<TopologyNodeModel> nodes;
  final TopologyNodeModel? selectedNode;

  TopologyPainter({required this.nodes, this.selectedNode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0ea5e9).withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw connections
    for (final node in nodes) {
      final startPos = Offset(node.position.dx + 40, node.position.dy + 40);

      for (final connId in node.connections) {
        final targetNode = nodes.firstWhere(
          (n) => n.id == connId,
          orElse: () => node,
        );
        if (targetNode != node) {
          final endPos = Offset(
            targetNode.position.dx + 40,
            targetNode.position.dy + 40,
          );

          // Highlight connection if either node is selected
          if (selectedNode != null &&
              (node.id == selectedNode!.id ||
                  targetNode.id == selectedNode!.id)) {
            paint.color = const Color(0xFF0ea5e9);
            paint.strokeWidth = 3;
          } else {
            paint.color = const Color(0xFF0ea5e9).withOpacity(0.3);
            paint.strokeWidth = 2;
          }

          canvas.drawLine(startPos, endPos, paint);

          // Draw arrow
          _drawArrow(canvas, startPos, endPos, paint);
        }
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    final double arrowSize = 10.0;
    final double angle = (end - start).direction;

    final Offset arrowTip = end - Offset.fromDirection(angle, 40);
    final Offset arrowLeft =
        arrowTip - Offset.fromDirection(angle - 0.5, arrowSize);
    final Offset arrowRight =
        arrowTip - Offset.fromDirection(angle + 0.5, arrowSize);

    final path = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowLeft.dx, arrowLeft.dy)
      ..lineTo(arrowRight.dx, arrowRight.dy)
      ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(TopologyPainter oldDelegate) {
    return oldDelegate.selectedNode != selectedNode;
  }
}
