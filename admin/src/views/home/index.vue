<template>
  <div class="home-container">
    <!-- 统计卡片 -->
    <el-row :gutter="16" class="stat-cards">
      <el-col :span="6" v-for="card in statCards" :key="card.title">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-card-content">
            <div class="stat-info">
              <span class="stat-title">{{ card.title }}</span>
              <span class="stat-value">{{ card.value }}</span>
            </div>
            <el-icon :size="40" :color="card.color"><component :is="card.icon" /></el-icon>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="16" style="margin-top: 16px">
      <el-col :span="16">
        <el-card shadow="hover">
          <template #header>近7天订单趋势</template>
          <div ref="trendChartRef" style="height: 350px"></div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header>订单状态分布</template>
          <div ref="statusChartRef" style="height: 350px"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="16" style="margin-top: 16px">
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header>评分分布</template>
          <div ref="ratingChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header>平台概览</template>
          <div class="overview-list">
            <div class="overview-item" v-for="item in overviewList" :key="item.label">
              <span class="overview-label">{{ item.label }}</span>
              <span class="overview-value">{{ item.value }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed, markRaw } from "vue";
import { ShoppingCart, User, Van, Money, Star, Warning, TrendCharts, DataAnalysis } from "@element-plus/icons-vue";
import http from "@/api";
import * as echarts from "echarts";

const dashboardData = ref<any>({});
const trendChartRef = ref<HTMLElement>();
const statusChartRef = ref<HTMLElement>();
const ratingChartRef = ref<HTMLElement>();

const statCards = computed(() => [
  { title: "总订单数", value: dashboardData.value.totalOrders || 0, icon: markRaw(ShoppingCart), color: "#3B82F6" },
  { title: "今日订单", value: dashboardData.value.todayOrders || 0, icon: markRaw(TrendCharts), color: "#10B981" },
  { title: "总收入(元)", value: "¥" + (dashboardData.value.totalGMV || 0), icon: markRaw(Money), color: "#F59E0B" },
  { title: "总用户数", value: dashboardData.value.totalUsers || 0, icon: markRaw(User), color: "#8B5CF6" }
]);

const overviewList = computed(() => [
  { label: "骑手数量", value: dashboardData.value.totalRiders || 0 },
  { label: "平均评分", value: (dashboardData.value.avgRating || 0) + " 分" },
  { label: "待处理订单", value: dashboardData.value.pendingOrders || 0 },
  { label: "完成率", value: dashboardData.value.totalOrders ? ((((dashboardData.value.statusDistribution || {})["COMPLETED"] || 0) / dashboardData.value.totalOrders) * 100).toFixed(1) + "%" : "0%" }
]);

const statusNameMap: Record<string, string> = {
  PENDING_PAY: "待支付", PAID: "已支付", ASSIGNED: "已派单", PICKED_UP: "已取件",
  WASHING: "清洗中", WASHED: "已清洗", DELIVERING: "配送中", COMPLETED: "已完成",
  CANCELLED: "已取消", REVIEWED: "已评价"
};

const initCharts = () => {
  // 订单趋势图
  if (trendChartRef.value) {
    const chart = echarts.init(trendChartRef.value);
    const trend = dashboardData.value.orderTrend || [];
    chart.setOption({
      tooltip: { trigger: "axis" },
      xAxis: { type: "category", data: trend.map((t: any) => t.date) },
      yAxis: { type: "value" },
      series: [{ data: trend.map((t: any) => t.count), type: "line", smooth: true, areaStyle: { opacity: 0.3 }, lineStyle: { color: "#3B82F6" }, itemStyle: { color: "#3B82F6" } }],
      grid: { top: 20, right: 20, bottom: 30, left: 50 }
    });
  }

  // 订单状态分布饼图
  if (statusChartRef.value) {
    const chart = echarts.init(statusChartRef.value);
    const dist = dashboardData.value.statusDistribution || {};
    chart.setOption({
      tooltip: { trigger: "item" },
      series: [{ type: "pie", radius: ["40%", "70%"], data: Object.entries(dist).map(([k, v]) => ({ name: statusNameMap[k] || k, value: v })), label: { show: true, formatter: "{b}: {c}" } }]
    });
  }

  // 评分分布柱状图
  if (ratingChartRef.value) {
    const chart = echarts.init(ratingChartRef.value);
    const dist = dashboardData.value.ratingDistribution || {};
    chart.setOption({
      tooltip: { trigger: "axis" },
      xAxis: { type: "category", data: ["1星", "2星", "3星", "4星", "5星"] },
      yAxis: { type: "value" },
      series: [{ data: [1, 2, 3, 4, 5].map(r => dist[r] || 0), type: "bar", itemStyle: { color: "#F59E0B", borderRadius: [4, 4, 0, 0] } }],
      grid: { top: 20, right: 20, bottom: 30, left: 50 }
    });
  }
};

onMounted(async () => {
  try {
    const { data } = await http.get("/statistics/dashboard");
    dashboardData.value = data;
    setTimeout(initCharts, 100);
  } catch (e) {
    console.error("获取看板数据失败", e);
  }
});
</script>

<style scoped lang="scss">
.home-container { padding: 0; }
.stat-card { .stat-card-content { display: flex; align-items: center; justify-content: space-between; }
  .stat-info { display: flex; flex-direction: column; }
  .stat-title { color: #909399; font-size: 14px; margin-bottom: 8px; }
  .stat-value { font-size: 28px; font-weight: 700; color: #303133; }
}
.overview-list { padding: 10px 0;
  .overview-item { display: flex; justify-content: space-between; align-items: center; padding: 14px 16px; border-bottom: 1px solid #f0f0f0;
    &:last-child { border-bottom: none; }
    .overview-label { color: #606266; font-size: 14px; }
    .overview-value { font-size: 18px; font-weight: 600; color: #303133; }
  }
}
</style>
