import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'chartStyles.dart';

class WeeklyPointsChart extends StatefulWidget {
  final Color lineColor;

  final Color indicatorLineColor;
  final Color indicatorTouchedLineColor;
  final Color indicatorSpotStrokeColor;
  final Color indicatorTouchedSpotStrokeColor;
  final Color bottomTextColor;
  final Color bottomTouchedTextColor;
  final Color tooltipBgColor;
  final Color tooltipTextColor;
  final List<double> yValues;
  WeeklyPointsChart({
    super.key,
    required this.yValues,
    Color? lineColor,
    Color? indicatorLineColor,
    Color? indicatorTouchedLineColor,
    Color? indicatorSpotStrokeColor,
    Color? indicatorTouchedSpotStrokeColor,
    Color? bottomTextColor,
    Color? bottomTouchedTextColor,
    Color? tooltipBgColor,
    Color? tooltipTextColor,
  })  : lineColor = lineColor ?? ChartColors.contentColorRed,
        indicatorLineColor = indicatorLineColor ??
            ChartColors.contentColorYellow.withOpacity(0.2),
        indicatorTouchedLineColor =
            indicatorTouchedLineColor ?? ChartColors.contentColorYellow,
        indicatorSpotStrokeColor = indicatorSpotStrokeColor ??
            ChartColors.contentColorYellow.withOpacity(0.5),
        indicatorTouchedSpotStrokeColor =
            indicatorTouchedSpotStrokeColor ?? ChartColors.contentColorYellow,
        bottomTextColor =
            bottomTextColor ?? ChartColors.contentColorYellow.withOpacity(0.2),
        bottomTouchedTextColor =
            bottomTouchedTextColor ?? ChartColors.contentColorYellow,
        tooltipBgColor = tooltipBgColor ?? ChartColors.contentColorGreen,
        tooltipTextColor = tooltipTextColor ?? Colors.black;

  // order week days with current day at the end
  List<String> get weekDays {
    final now = DateTime.now();
    final todayIndex = now.weekday % 7; // Ensure index is between 0 and 6
    final days = [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ];
    return [...days.sublist(todayIndex), ...days.sublist(0, todayIndex)]
        .reversed
        .toList();
  }

  @override
  State createState() => _WeeklyPointsChartState();
}

class _WeeklyPointsChartState extends State<WeeklyPointsChart> {
  late double touchedValue;

  bool fitInsideBottomTitle = true;
  bool fitInsideLeftTitle = false;

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final isTouched = value == touchedValue;
    final style = TextStyle(
      color: isTouched ? widget.bottomTouchedTextColor : widget.bottomTextColor,
      fontWeight: FontWeight.bold,
    );

    if (value % 1 != 0) {
      return Container();
    }
    return SideTitleWidget(
      space: 4,
      axisSide: meta.axisSide,
      fitInside: fitInsideBottomTitle
          ? SideTitleFitInsideData.fromTitleMeta(meta, distanceFromEdge: 0)
          : SideTitleFitInsideData.disable(),
      child: Text(
        widget.weekDays[value.toInt()],
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(
          height: 18,
        ),
        AspectRatio(
          aspectRatio: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 0, left: 0),
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      final spot = barData.spots[spotIndex];
                      if (spot.x == 0 || spot.x == 6) {
                        return null;
                      }
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: widget.indicatorTouchedLineColor,
                          strokeWidth: 4,
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            if (index.isEven) {
                              return FlDotCirclePainter(
                                radius: 8,
                                color: Colors.white,
                                strokeWidth: 5,
                                strokeColor:
                                    widget.indicatorTouchedSpotStrokeColor,
                              );
                            } else {
                              return FlDotSquarePainter(
                                size: 16,
                                color: Colors.white,
                                strokeWidth: 5,
                                strokeColor:
                                    widget.indicatorTouchedSpotStrokeColor,
                              );
                            }
                          },
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        if (flSpot.x == 0 || flSpot.x == 6) {
                          return null;
                        }

                        TextAlign textAlign;
                        switch (flSpot.x.toInt()) {
                          case 1:
                            textAlign = TextAlign.left;
                            break;
                          case 5:
                            textAlign = TextAlign.right;
                            break;
                          default:
                            textAlign = TextAlign.center;
                        }

                        return LineTooltipItem(
                          '${widget.weekDays[flSpot.x.toInt()]} \n',
                          TextStyle(
                            color: widget.tooltipTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: flSpot.y.toString(),
                              style: TextStyle(
                                color: widget.tooltipTextColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const TextSpan(
                              text: ' points',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                          textAlign: textAlign,
                        );
                      }).toList();
                    },
                  ),
                  touchCallback:
                      (FlTouchEvent event, LineTouchResponse? lineTouch) {
                    if (!event.isInterestedForInteractions ||
                        lineTouch == null ||
                        lineTouch.lineBarSpots == null) {
                      setState(() {
                        touchedValue = -1;
                      });
                      return;
                    }
                    final value = lineTouch.lineBarSpots![0].x;

                    if (value == 0 || value == 6) {
                      setState(() {
                        touchedValue = -1;
                      });
                      return;
                    }

                    setState(() {
                      touchedValue = value;
                    });
                  },
                ),
                lineBarsData: [
                  LineChartBarData(
                    isStepLineChart: true,
                    spots: widget.yValues.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: false,
                    barWidth: 4,
                    color: widget.lineColor,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          widget.lineColor.withOpacity(0.5),
                          widget.lineColor.withOpacity(0),
                        ],
                        stops: const [0.5, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      spotsLine: BarAreaSpotsLine(
                        show: true,
                        flLineStyle: FlLine(
                          color: widget.indicatorLineColor,
                          strokeWidth: 2,
                        ),
                        checkToShowSpotLine: (spot) {
                          if (spot.x == 0 || spot.x == 6) {
                            return false;
                          }

                          return true;
                        },
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (index.isEven) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: widget.indicatorSpotStrokeColor,
                          );
                        } else {
                          return FlDotSquarePainter(
                            size: 12,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: widget.indicatorSpotStrokeColor,
                          );
                        }
                      },
                      checkToShowDot: (spot, barData) {
                        return spot.x != 0 && spot.x != 6;
                      },
                    ),
                  ),
                ],
                minY: 0,
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: ChartColors.borderColor,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  checkToShowHorizontalLine: (value) => value % 1 == 0,
                  checkToShowVerticalLine: (value) => value % 1 == 0,
                  getDrawingHorizontalLine: (value) {
                    if (value == 0) {
                      return const FlLine(
                        color: ChartColors.contentColorOrange,
                        strokeWidth: 2,
                      );
                    } else {
                      return const FlLine(
                        color: ChartColors.mainGridLineColor,
                        strokeWidth: 0.5,
                      );
                    }
                  },
                  getDrawingVerticalLine: (value) {
                    if (value == 0) {
                      return const FlLine(
                        color: Colors.redAccent,
                        strokeWidth: 10,
                      );
                    } else {
                      return const FlLine(
                        color: ChartColors.mainGridLineColor,
                        strokeWidth: 0.5,
                      );
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    touchedValue = -1;
    super.initState();
  }
}
