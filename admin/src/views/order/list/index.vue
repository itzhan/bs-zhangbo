<template>
  <div class="table-box">
    <el-form :inline="true" :model="searchForm" class="search-form">
      <el-form-item label="状态">
        <el-select v-model="searchForm.status" placeholder="全部" clearable style="width: 140px">
          <el-option v-for="s in statusOptions" :key="s.value" :label="s.label" :value="s.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="fetchData">查询</el-button>
      </el-form-item>
    </el-form>

    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="orderNo" label="订单编号" width="180" />
      <el-table-column prop="contactName" label="联系人" width="100" />
      <el-table-column prop="contactPhone" label="电话" width="130" />
      <el-table-column prop="addressDetail" label="地址" show-overflow-tooltip />
      <el-table-column prop="pickupTime" label="取件时段" width="140" />
      <el-table-column prop="totalAmount" label="金额" width="100">
        <template #default="{ row }">¥{{ row.totalAmount }}</template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="statusTagType(row.status)">{{ statusMap[row.status] || row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createdAt" label="下单时间" width="170" />
      <el-table-column label="操作" width="240" fixed="right">
        <template #default="{ row }">
          <el-button size="small" @click="viewDetail(row)">详情</el-button>
          <el-button size="small" type="warning" v-if="row.status==='PAID'" @click="assignRider(row)">派单</el-button>
          <el-button size="small" type="primary" v-if="canAdvance(row.status)" @click="advanceStatus(row)">推进</el-button>
          <el-button size="small" type="danger" v-if="canCancel(row.status)" @click="cancelOrder(row)">取消</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination v-model:current-page="page" v-model:page-size="size" :total="total" layout="total, prev, pager, next" @current-change="fetchData" style="margin-top: 16px; justify-content: flex-end" />

    <!-- 派单弹窗 -->
    <el-dialog v-model="assignVisible" title="派单" width="400px">
      <el-form>
        <el-form-item label="选择骑手">
          <el-select v-model="selectedRiderId" placeholder="请选择骑手" style="width: 100%">
            <el-option v-for="r in riderList" :key="r.id" :label="r.nickname + ' (' + r.phone + ')'" :value="r.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="assignVisible = false">取消</el-button>
        <el-button type="primary" @click="doAssign">确认派单</el-button>
      </template>
    </el-dialog>

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailVisible" title="订单详情" width="700px">
      <el-descriptions :column="2" border v-if="detailData.order">
        <el-descriptions-item label="订单编号">{{ detailData.order.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="状态"><el-tag :type="statusTagType(detailData.order.status)">{{ statusMap[detailData.order.status] }}</el-tag></el-descriptions-item>
        <el-descriptions-item label="联系人">{{ detailData.order.contactName }}</el-descriptions-item>
        <el-descriptions-item label="电话">{{ detailData.order.contactPhone }}</el-descriptions-item>
        <el-descriptions-item label="地址" :span="2">{{ detailData.order.addressDetail }}</el-descriptions-item>
        <el-descriptions-item label="取件时段">{{ detailData.order.pickupDate }} {{ detailData.order.pickupTime }}</el-descriptions-item>
        <el-descriptions-item label="总金额">¥{{ detailData.order.totalAmount }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ detailData.order.remark || '无' }}</el-descriptions-item>
      </el-descriptions>
      <el-table :data="detailData.items || []" border size="small" style="margin-top: 16px">
        <el-table-column prop="serviceName" label="服务项目" />
        <el-table-column prop="price" label="单价" width="100"><template #default="{row}">¥{{ row.price }}</template></el-table-column>
        <el-table-column prop="quantity" label="数量" width="80" />
        <el-table-column prop="subtotal" label="小计" width="100"><template #default="{row}">¥{{ row.subtotal }}</template></el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import http from "@/api";
import { ElMessage, ElMessageBox } from "element-plus";

const loading = ref(false);
const tableData = ref<any[]>([]);
const page = ref(1);
const size = ref(10);
const total = ref(0);
const searchForm = ref({ status: "" });
const assignVisible = ref(false);
const detailVisible = ref(false);
const selectedRiderId = ref<number>();
const currentOrder = ref<any>({});
const detailData = ref<any>({});
const riderList = ref<any[]>([]);

const statusOptions = [
  { label: "待支付", value: "PENDING_PAY" }, { label: "已支付", value: "PAID" },
  { label: "已派单", value: "ASSIGNED" }, { label: "已取件", value: "PICKED_UP" },
  { label: "清洗中", value: "WASHING" }, { label: "已清洗", value: "WASHED" },
  { label: "配送中", value: "DELIVERING" }, { label: "已完成", value: "COMPLETED" },
  { label: "已取消", value: "CANCELLED" }
];
const statusMap: Record<string, string> = Object.fromEntries(statusOptions.map(s => [s.value, s.label]));
const statusTagType = (s: string) => ({ COMPLETED: "success", CANCELLED: "info", PENDING_PAY: "warning", PAID: "", ASSIGNED: "", PICKED_UP: "", WASHING: "", WASHED: "", DELIVERING: "primary" }[s] || "");
const nextStatus: Record<string, string> = { ASSIGNED: "PICKED_UP", PICKED_UP: "WASHING", WASHING: "WASHED", WASHED: "DELIVERING", DELIVERING: "COMPLETED" };
const canAdvance = (s: string) => !!nextStatus[s];
const canCancel = (s: string) => ["PENDING_PAY", "PAID", "ASSIGNED"].includes(s);

const fetchData = async () => {
  loading.value = true;
  try {
    const { data } = await http.get("/orders", { page: page.value, size: size.value, status: searchForm.value.status || undefined });
    tableData.value = data.records;
    total.value = data.total;
  } finally { loading.value = false; }
};

const viewDetail = async (row: any) => {
  const { data } = await http.get(`/orders/${row.id}`);
  detailData.value = data;
  detailVisible.value = true;
};

const assignRider = async (row: any) => {
  currentOrder.value = row;
  const { data } = await http.get("/admin/users", { role: "RIDER", page: 1, size: 100 });
  riderList.value = data.records;
  assignVisible.value = true;
};

const doAssign = async () => {
  if (!selectedRiderId.value) return ElMessage.warning("请选择骑手");
  await http.post(`/orders/${currentOrder.value.id}/assign`, { riderId: selectedRiderId.value });
  ElMessage.success("派单成功");
  assignVisible.value = false;
  fetchData();
};

const advanceStatus = async (row: any) => {
  const ns = nextStatus[row.status];
  await ElMessageBox.confirm(`确认将订单推进到 ${statusMap[ns] || ns}？`, "提示");
  await http.put(`/orders/${row.id}/status`, { status: ns });
  ElMessage.success("状态更新成功");
  fetchData();
};

const cancelOrder = async (row: any) => {
  await ElMessageBox.confirm("确认取消此订单？", "警告", { type: "warning" });
  await http.post(`/orders/${row.id}/cancel`, { reason: "管理员取消" });
  ElMessage.success("取消成功");
  fetchData();
};

onMounted(fetchData);
</script>

<style scoped>
.search-form { margin-bottom: 16px; }
</style>
