<template>
  <div class="table-box">
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="id" label="ID" width="60" />
      <el-table-column prop="configKey" label="配置键" width="200" />
      <el-table-column prop="configValue" label="配置值" width="200">
        <template #default="{row}"><el-input v-model="row.configValue" size="small" /></template>
      </el-table-column>
      <el-table-column prop="description" label="说明" show-overflow-tooltip />
      <el-table-column label="操作" width="100" fixed="right">
        <template #default="{row}"><el-button size="small" type="primary" @click="save(row)">保存</el-button></template>
      </el-table-column>
    </el-table>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from "vue";
import http from "@/api";
import { ElMessage } from "element-plus";
const loading = ref(false), tableData = ref<any[]>([]);
const fetchData = async () => { loading.value = true; try { const { data } = await http.get("/system-configs"); tableData.value = data; } finally { loading.value = false; } };
const save = async (row: any) => { await http.put("/system-configs/" + row.id, row); ElMessage.success("保存成功"); };
onMounted(fetchData);
</script>
