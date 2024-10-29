import 'package:chaeyeon/providers/major_provider.dart';
import 'package:flutter/material.dart';
import 'package:chaeyeon/data/major_data.dart';
import 'package:chaeyeon/widgets/search_major.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MajorList extends ConsumerStatefulWidget {
  const MajorList({
    super.key,
  });

  @override
  ConsumerState<MajorList> createState() => _MajorListState();
}

class _MajorListState extends ConsumerState<MajorList> {
  String searchText = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final majors = ref.watch(majorProvider);
    majors.sort((a, b) => a.major.compareTo(b.major));

    return Column(
      children: [
        SearchMajor(
          onSearchChanged: (newText) {
            setState(() {
              searchText = newText;
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: majors.length,
            itemBuilder: (BuildContext context, int index) {
              if (searchText.isNotEmpty &&
                  !majors[index].major
                      .toLowerCase()
                      .contains(searchText.toLowerCase())) {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (majors.contains(majors[index])) {
                      widget.selectedMajor.remove(majors[index]);
                    } else if (widget.selectedMajor.length < 2) {
                      widget.selectedMajor.add(majors[index]);
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.white,
                            title: const Text(
                              '전공 선택 제한',
                              style: TextStyle(
                                color: Color(0xFF0B5B42),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("전공은 최대 두 개까지 선택할 수 있습니다."),
                                const SizedBox(height: 10),
                                Text(
                                  "선택한 전공: \n ${widget.selectedMajor.join('\n ')}",
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('확인',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    widget.onSelectedMajorChanged(widget.selectedMajor);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 1,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFD9D9D9),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          majors[index],
                          style: TextStyle(
                            fontSize: 17.5,
                            fontWeight:
                                widget.selectedMajor.contains(majors[index])
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                            color: widget.selectedMajor.contains(majors[index])
                                ? const Color(0xFF0B5B42)
                                : const Color(0xFF979797),
                          ),
                        ),
                        if (widget.selectedMajor.contains(majors[index]))
                          const Icon(Icons.check,
                              color: Color(0xFF0B5B42), size: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
