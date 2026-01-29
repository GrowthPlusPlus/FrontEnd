// 최초 작성자 : 김채영
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/widgets/custom_bottom_sheet.dart';
import 'custom_edit_screen.dart';

// 커스텀 갤러리 화면
class CustomGalleryScreen extends StatefulWidget {
  final List<AssetEntity> initialSelectedAssets; // 이전 선택 항목을 받기 위한 프로퍼티 추가
  const CustomGalleryScreen({super.key, this.initialSelectedAssets = const []});

  @override
  State<CustomGalleryScreen> createState() => _CustomGalleryScreenState();
}

class _CustomGalleryScreenState extends State<CustomGalleryScreen> {
  List<AssetPathEntity> _paths = []; // 전체 폴더 목록
  AssetPathEntity? _selectedPath; // 현재 선택된 폴더
  final List<AssetEntity> _assets = []; // 현재 폴더의 사진들
  final List<AssetEntity> _selectedAssets = [];

  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final _maxImages = 3;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _selectedAssets.addAll(
      widget.initialSelectedAssets,
    ); // 시작할 때 부모로부터 받은 사진들을 리스트에 미리 담기

    _fetchInitialData(); // 폴더 목록부터 가져오기
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _fetchAssets();
      }
    });
  }

  // 초기 데이터 로드
  Future<void> _fetchInitialData() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth || ps.hasAccess) {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );

      if (paths.isNotEmpty && mounted) {
        setState(() {
          _paths = paths;
          _selectedPath = paths[0]; // 기본값: 전체 보기 혹은 첫 번째 폴더
        });
        _fetchAssets();
      }
    }
  }

  // 현재 선택된 폴더에서 사진 가져오기
  Future<void> _fetchAssets() async {
    if (_isLoading || !_hasMore || _selectedPath == null) return;

    setState(() => _isLoading = true);

    final List<AssetEntity> entities = await _selectedPath!.getAssetListRange(
      start: _currentPage * 60,
      end: (_currentPage + 1) * 60,
    );

    if (mounted) {
      setState(() {
        if (entities.isEmpty) {
          _hasMore = false;
        } else {
          _assets.addAll(entities);
          _currentPage++;
        }
        _isLoading = false;
      });
    }
  }

  // 폴더 변경 시 호출
  void _onPathChanged(AssetPathEntity path) {
    if (_selectedPath == path) return;
    setState(() {
      _selectedPath = path;
      _assets.clear(); // 기존 사진 비우기
      _currentPage = 0;
      _hasMore = true;
    });
    _fetchAssets();
    Navigator.pop(context); // 바텀시트 닫기
  }

  // 사진 폴더 선택 바텀시트
  void _showFolderList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomBottomSheet(
          title: '폴더 선택',
          heightFactor: 0.6,
          child: ListView.builder(
            itemCount: _paths.length,
            itemBuilder: (context, index) {
              final path = _paths[index];
              return ListTile(
                title: Text(
                  path.isAll ? '갤러리' : path.name,
                  style: AppTypography.b1,
                ),
                trailing: FutureBuilder<int>(
                  future: path.assetCountAsync,
                  builder: (context, snapshot) => Text('${snapshot.data ?? 0}'),
                ),
                onTap: () => _onPathChanged(path),
                selected: _selectedPath == path,
                selectedTileColor: AppColors.selected,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: GestureDetector(
          onTap: _showFolderList, // 클릭 시 폴더 목록 표시
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (_selectedPath?.isAll == true)
                    ? '갤러리'
                    : (_selectedPath?.name ?? '갤러리'),
                style: AppTypography.h3.copyWith(color: AppColors.black),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(
                'assets/images/icons/small_down_arrow.svg',
                width: 15,
                height: 15,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _selectedAssets.isNotEmpty
                ? () async {
                    // 편집 화면으로 먼저 이동
                    final List<File>? editedFiles = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CustomEditScreen(selectedAssets: _selectedAssets),
                      ),
                    );

                    // 편집이 완료되어 파일 리스트가 돌아오면, 에셋 정보와 함께 부모에게 전달
                    if (editedFiles != null && mounted) {
                      Navigator.pop(context, {
                        'files': editedFiles, // 최종 편집된 파일들
                        'assets': _selectedAssets, // 선택된 갤러리 원본들 (상태 유지용)
                      });
                    }
                  }
                : null,
            child: Text(
              '완료',
              style: AppTypography.b1.copyWith(
                color: _selectedAssets.isNotEmpty
                    ? AppColors.black
                    : AppColors.gray3,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: _assets.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _assets.length,
              itemBuilder: (context, index) {
                if (index >= _assets.length) return const SizedBox.shrink();

                final asset = _assets[index];
                final isSelected = _selectedAssets.contains(asset);
                final selectOrder = _selectedAssets.indexOf(asset) + 1;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedAssets.remove(asset);
                      } else if (_selectedAssets.length < _maxImages) {
                        _selectedAssets.add(asset);
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AssetEntityImage(
                          asset,
                          isOriginal: false,
                          thumbnailSize: const ThumbnailSize.square(250),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primaryAble
                                : Colors.transparent,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: isSelected
                              ? Text(
                                  '$selectOrder',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (isSelected)
                        Container(color: Colors.white.withAlpha(80)),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
