import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/GraphView.dart';
import 'package:md_notes/bloc/directory/directory_bloc.dart';
import 'package:md_notes/bloc/directory/directory_events.dart';
import 'package:md_notes/bloc/directory/directory_states.dart';
import 'package:md_notes/code_kit/constants/app_constants.dart';
import 'package:md_notes/code_kit/extensions/status_enum_extension.dart';
import 'package:md_notes/presentation/screens/graph/widgets/node_widget.dart';
import 'package:path/path.dart' as p;

class GraphViewScreen extends StatefulWidget {
  const GraphViewScreen({
    super.key,
    required this.rootPath,
  });

  final String rootPath;

  @override
  State<GraphViewScreen> createState() => _GraphViewScreenState();
}

class _GraphViewScreenState extends State<GraphViewScreen> {
  final _graph = Graph()..isTree=true;
  final _graphToOverlay = Graph();
  bool _canRenderGraph = false;
  bool _startOverlay = true;
  final BuchheimWalkerConfiguration _builder = BuchheimWalkerConfiguration()
    ..siblingSeparation = 10 // Увеличено для большего расстояния между соседями
    ..levelSeparation = 1    // Увеличено для большего расстояния между уровнями
    ..subtreeSeparation = 1 // Увеличено для большего расстояния между поддеревьями
    ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT;


  @override
  void initState() {
    super.initState();
    _fillGraph(context.read<DirectoryBloc>().state.nodesWithLevels);
    _fillOverlayedGraph();
  }

  _fillOverlayedGraph() {
    for (int i = 0; i <= 15; i++) {
      _graphToOverlay.addNode(Node.Id(i));
    }
  }

  void _fillGraph(List<Map<FileSystemEntity, int>>? nodesWithLevels) {
    if (nodesWithLevels == null || nodesWithLevels.isEmpty) {
      setState(() {
        _startOverlay = true;
      });
      return;
    }

    // Карта для хранения узлов по их абсолютным путям
    Map<String, Node> nodes = {};

    // Добавляем фиктивный корень
    const dummyRootId = "dummy_root";
    final dummyRootNode = Node.Id(dummyRootId);
    _graph.addNode(dummyRootNode);
    nodes[dummyRootId] = dummyRootNode;

    // 1. Добавляем все узлы в граф
    for (var nodeWithLevel in nodesWithLevels) {
      for (var entry in nodeWithLevel.entries) {
        final entity = entry.key;
        final nodeId = entity.absolute.path;
        if (!nodes.containsKey(nodeId)) {
          final node = Node.Id(nodeId);
          _graph.addNode(node);
          nodes[nodeId] = node;
        }
      }
    }

    // Множество для отслеживания узлов с входящими ребрами
    Set<String> nodesWithIncomingEdges = {};

    // 2. Добавляем ребра между родителями и детьми
    for (var nodeWithLevel in nodesWithLevels) {
      for (var entry in nodeWithLevel.entries) {
        final entity = entry.key;
        final nodeId = entity.absolute.path;
        final parentPath = entity.parent.path;

        // Проверяем существование родителя и исключаем самоссылки
        if (nodes.containsKey(parentPath) && parentPath != nodeId) {
          _graph.addEdge(nodes[parentPath]!, nodes[nodeId]!);
          nodesWithIncomingEdges.add(nodeId);
        }
      }
    }

    // 3. Подключаем узлы без входящих ребер к фиктивному корню
    for (var nodeId in nodes.keys) {
      if (nodeId != dummyRootId && !nodesWithIncomingEdges.contains(nodeId)) {
        _graph.addEdge(dummyRootNode, nodes[nodeId]!);
      }
    }

    setState(() {
      _canRenderGraph = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DirectoryBloc>();

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: bloc.state.nodesWithLevels != null &&
          bloc.state.nodesWithLevels!.isNotEmpty
          ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            "/home",
          );
        },
        shape: CircleBorder(),
        child: Icon(
          Icons.add,
        ),
      )
          : null,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder(
            bloc: context.read<DirectoryBloc>(),
            builder: (BuildContext context, DirectoryState state) {
              if (state.nodesWithLevels != null &&
                  _canRenderGraph &&
                  state.status.isSuccess()) {
                return Expanded(
                  child: InteractiveViewer(
                    minScale: 0.1,
                    maxScale: 2.0,
                    boundaryMargin: EdgeInsets.all(20),
                    constrained: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GraphView(
                        graph: _graph,
                        algorithm: BuchheimWalkerAlgorithm(_builder, TreeEdgeRenderer(_builder)),
                        builder: (Node node) {
                          final id = node.key?.value as String;
                          if (id == "dummy_root") {
                            return NodeWidget(
                              title: "Root",
                              folderType: true,
                            );
                          }
                          final entityType = id.contains(".md") ? "file" : "folder";
                          if (entityType == "file") {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/canvas',
                                  arguments: id,
                                );
                              },
                              child: NodeWidget(
                                // title: p.basename(id).length > 5
                                //     ? "${p.basename(id).replaceRange(5, null, "")}..."
                                //     : p.basename(id),
                                title: p.basename(id),
                                folderType: false,
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                context.read<DirectoryBloc>().add(ToggleFolder(id));
                                if (!state.folderContents.containsKey(id)) {
                                  context.read<DirectoryBloc>().add(
                                    FetchDirectory(path: id),
                                  );
                                }
                                Navigator.pushNamed(
                                  context,
                                  '/home',
                                  arguments: id,
                                );
                              },
                              child: NodeWidget(
                                title: p.basename(id),
                                folderType: true,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
              } else if (state.status.isSuccess()) {
                return Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GraphView(
                        graph: _graphToOverlay,
                        algorithm: FruchtermanReingoldAlgorithm(),
                        builder: (Node node) {
                          return NodeWidget(
                            title: AppConstants
                                .mockNotesList[node.key?.value ?? 1],
                            folderType: node.key?.value % 3 == 0,
                          );
                        },
                      ),
                      Positioned(
                        top: 200,
                        child: Container(
                          height: 150,
                          width: 270,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                            Theme.of(context).primaryColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "No .md files found",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed("/home");
                                },
                                child: Text(
                                  "Press here to Create",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state.status.isLoading()) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}