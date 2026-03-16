<template>
  <div class="dataVisualize-box">
    <!-- 顶部统计卡片 -->
    <el-row :gutter="20" class="stat-cards">
      <el-col :xs="12" :sm="12" :md="6" :lg="6" v-for="card in statCards" :key="card.title">
        <div class="stat-card" :style="{ background: card.bg }">
          <div class="stat-card-icon" v-html="card.svg"></div>
          <div class="stat-card-info">
            <div class="stat-card-value">{{ card.value }}</div>
            <div class="stat-card-title">{{ card.title }}</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :xs="24" :sm="24" :md="16" :lg="16">
        <div class="card chart-box">
          <div class="chart-title">近7天订单趋势</div>
          <div class="chart-wrap">
            <ECharts :option="orderTrendOption" v-if="loaded" />
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="24" :md="8" :lg="8">
        <div class="card chart-box">
          <div class="chart-title">订单状态分布</div>
          <div class="chart-wrap">
            <ECharts :option="statusPieOption" v-if="loaded" />
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 底部信息区 -->
    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :xs="24" :sm="24" :md="12" :lg="12">
        <div class="card info-box">
          <div class="chart-title">平台概览</div>
          <div class="overview-list">
            <div class="overview-item" v-for="item in overviewItems" :key="item.label">
              <span class="overview-label">{{ item.label }}</span>
              <span class="overview-value" :style="{ color: item.color || '#333' }">{{ item.value }}</span>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="24" :md="12" :lg="12">
        <div class="card chart-box">
          <div class="chart-title">用户评分分布</div>
          <div class="chart-wrap">
            <ECharts :option="ratingOption" v-if="loaded" />
          </div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts" name="dataVisualize">
import { ref, reactive, onMounted, computed } from "vue";
import { ECOption } from "@/components/ECharts/config";
import ECharts from "@/components/ECharts/index.vue";
import { useUserStore } from "@/stores/modules/user";
import axios from "axios";

const userStore = useUserStore();
const loaded = ref(false);

const dashboard = reactive({
  totalOrders: 0,
  todayOrders: 0,
  totalGMV: 0,
  pendingOrders: 0,
  totalUsers: 0,
  totalRiders: 0,
  avgRating: 0,
  orderTrend: [] as { date: string; count: number }[],
  statusDistribution: {} as Record<string, number>,
  ratingDistribution: {} as Record<string, number>
});

const statCards = computed(() => [
  {
    title: "今日订单",
    value: dashboard.todayOrders,
    bg: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
    svg: '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m7.5 4.27 9 5.15"/><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/></svg>'
  },
  {
    title: "累计营收(元)",
    value: "¥" + dashboard.totalGMV.toFixed(2),
    bg: "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)",
    svg: '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" x2="12" y1="2" y2="22"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>'
  },
  {
    title: "待处理订单",
    value: dashboard.pendingOrders,
    bg: "linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)",
    svg: '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>'
  },
  {
    title: "注册用户",
    value: dashboard.totalUsers,
    bg: "linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)",
    svg: '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" x2="19" y1="8" y2="14"/><line x1="22" x2="16" y1="11" y2="11"/></svg>'
  }
]);

const overviewItems = computed(() => [
  { label: "累计订单", value: dashboard.totalOrders + " 单", color: "#2563eb" },
  { label: "活跃骑手", value: dashboard.totalRiders + " 人", color: "#7c3aed" },
  { label: "用户评分", value: dashboard.avgRating + " 分", color: "#f59e0b" },
  { label: "今日新增", value: dashboard.todayOrders + " 单", color: "#10b981" }
]);

const statusNameMap: Record<string, string> = {
  PENDING_PAY: "待支付",
  PAID: "已支付",
  ASSIGNED: "已派单",
  PICKED_UP: "已取件",
  WASHING: "清洗中",
  WASHED: "已清洗",
  DELIVERING: "配送中",
  COMPLETED: "已完成",
  CANCELLED: "已取消"
};

const orderTrendOption = computed<ECOption>(() => ({
  tooltip: { trigger: "axis" },
  grid: { left: 50, right: 20, top: 30, bottom: 30 },
  xAxis: {
    type: "category",
    data: dashboard.orderTrend.map(i => i.date.substring(5)),
    axisLabel: { color: "#999" },
    axisLine: { lineStyle: { color: "#e5e5e5" } }
  },
  yAxis: {
    type: "value",
    minInterval: 1,
    axisLabel: { color: "#999" },
    splitLine: { lineStyle: { color: "#f0f0f0" } }
  },
  series: [
    {
      type: "line",
      data: dashboard.orderTrend.map(i => i.count),
      smooth: true,
      symbol: "circle",
      symbolSize: 8,
      lineStyle: { width: 3, color: "#2563eb" },
      itemStyle: { color: "#2563eb" },
      areaStyle: {
        color: {
          type: "linear",
          x: 0,
          y: 0,
          x2: 0,
          y2: 1,
          colorStops: [
            { offset: 0, color: "rgba(37,99,235,0.3)" },
            { offset: 1, color: "rgba(37,99,235,0.02)" }
          ]
        }
      }
    }
  ]
}));

const statusPieOption = computed<ECOption>(() => {
  const entries = Object.entries(dashboard.statusDistribution);
  return {
    tooltip: { trigger: "item", formatter: "{b}: {c} ({d}%)" },
    legend: { bottom: 0, textStyle: { fontSize: 12, color: "#999" } },
    series: [
      {
        type: "pie",
        radius: ["40%", "65%"],
        center: ["50%", "42%"],
        data: entries.map(([k, v]) => ({ name: statusNameMap[k] || k, value: v })),
        label: { show: false },
        emphasis: { label: { show: true, fontWeight: "bold" } },
        color: ["#2563eb", "#7c3aed", "#f59e0b", "#10b981", "#ef4444", "#6366f1", "#ec4899", "#14b8a6", "#f97316"]
      }
    ]
  };
});

const ratingOption = computed<ECOption>(() => {
  const entries = Object.entries(dashboard.ratingDistribution).sort(([a], [b]) => Number(a) - Number(b));
  return {
    tooltip: { trigger: "axis" },
    grid: { left: 50, right: 20, top: 20, bottom: 30 },
    xAxis: {
      type: "category",
      data: entries.map(([k]) => k + "星"),
      axisLabel: { color: "#999" },
      axisLine: { lineStyle: { color: "#e5e5e5" } }
    },
    yAxis: {
      type: "value",
      minInterval: 1,
      axisLabel: { color: "#999" },
      splitLine: { lineStyle: { color: "#f0f0f0" } }
    },
    series: [
      {
        type: "bar",
        data: entries.map(([, v]) => v),
        barWidth: "40%",
        itemStyle: {
          color: {
            type: "linear",
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: "#f59e0b" },
              { offset: 1, color: "#fbbf24" }
            ]
          },
          borderRadius: [6, 6, 0, 0]
        }
      }
    ]
  };
});

onMounted(async () => {
  try {
    const token = userStore.token;
    const { data: res } = await axios.get("/api/statistics/dashboard", {
      headers: { Authorization: `Bearer ${token}` }
    });
    if (res.code === 200 && res.data) {
      Object.assign(dashboard, res.data);
    }
  } catch (e) {
    console.error("获取仪表盘数据失败", e);
  } finally {
    loaded.value = true;
  }
});
</script>

<style scoped lang="scss">
.dataVisualize-box {
  padding: 0;
}
.stat-cards {
  .stat-card {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 24px 20px;
    border-radius: 14px;
    color: #fff;
    margin-bottom: 10px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
    transition: transform 0.2s;
    &:hover {
      transform: translateY(-3px);
    }
  }
  .stat-card-icon {
    flex-shrink: 0;
    width: 52px;
    height: 52px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 14px;
  }
  .stat-card-value {
    font-size: 28px;
    font-weight: 700;
    line-height: 1.2;
  }
  .stat-card-title {
    font-size: 14px;
    opacity: 0.85;
    margin-top: 4px;
  }
}
.card {
  background: var(--el-bg-color);
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  padding: 20px;
}
.chart-box {
  min-height: 340px;
}
.chart-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin-bottom: 16px;
  padding-left: 10px;
  border-left: 3px solid #2563eb;
}
.chart-wrap {
  height: 280px;
}
.info-box {
  min-height: 340px;
}
.overview-list {
  padding: 10px 0;
}
.overview-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 18px 16px;
  border-bottom: 1px solid #f5f5f5;
  &:last-child {
    border-bottom: none;
  }
}
.overview-label {
  font-size: 15px;
  color: #666;
}
.overview-value {
  font-size: 22px;
  font-weight: 700;
}
</style>
