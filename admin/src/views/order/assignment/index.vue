<template>
  <div class="table-box">
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="orderNo" label="订单编号" width="180" />
      <el-table-column prop="riderId" label="骑手ID" width="80" />
      <el-table-column prop="type" label="类型" width="100">
        <template #default="{row}"><el-tag>{{ row.type === 'PICKUP' ? '取件' : '送回' }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{row}">
          <el-tag :type="row.status==='COMPLETED'?'success':row.status==='PENDING'?'warning':''">{{ {PENDING:'待接单',ACCEPTED:'已接单',COMPLETED:'已完成'}[row.status] || row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="assignedAt" label="派单时间" width="170" />
      <el-table-column prop="acceptedAt" label="接单时间" width="170" />
      <el-table-column prop="completedAt" label="完成时间" width="170" />
      <el-table-column prop="remark" label="备注" show-overflow-tooltip />
    </el-table>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from "vue";
import http from "@/api";
const loading = ref(false);
const tableData = ref<any[]>([]);
const fetchData = async () => {
  loading.value = true;
  try {
    const { data } = await http.get("/orders", { page: 1, size: 100, status: "ASSIGNED" });
    tableData.value = data.records || [];
  } finally { loading.value = false; }
};
onMounted(fetchData);
</script>
