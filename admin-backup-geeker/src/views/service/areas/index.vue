<template>
  <div class="table-box">
    <el-form :inline="true" style="margin-bottom: 16px"
      ><el-form-item><el-button type="primary" @click="openForm()">新增区域</el-button></el-form-item></el-form
    >
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="id" label="ID" width="60" />
      <el-table-column prop="name" label="区域名称" width="150" />
      <el-table-column prop="city" label="城市" width="100" />
      <el-table-column prop="district" label="区县" width="100" />
      <el-table-column prop="description" label="描述" show-overflow-tooltip />
      <el-table-column prop="status" label="状态" width="80"
        ><template #default="{ row }"
          ><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? "启用" : "停用" }}</el-tag></template
        ></el-table-column
      >
      <el-table-column label="操作" width="150"
        ><template #default="{ row }"
          ><el-button size="small" @click="openForm(row)">编辑</el-button
          ><el-button size="small" type="danger" @click="del(row)">删除</el-button></template
        ></el-table-column
      >
    </el-table>
    <el-pagination
      v-model:current-page="page"
      :total="total"
      layout="total,prev,pager,next"
      @current-change="fetchData"
      style="margin-top: 16px; justify-content: flex-end"
    />
    <el-dialog v-model="formVisible" :title="formData.id ? '编辑区域' : '新增区域'" width="500px">
      <el-form :model="formData" label-width="80px">
        <el-form-item label="名称"><el-input v-model="formData.name" /></el-form-item>
        <el-form-item label="城市"><el-input v-model="formData.city" /></el-form-item>
        <el-form-item label="区县"><el-input v-model="formData.district" /></el-form-item>
        <el-form-item label="描述"><el-input v-model="formData.description" type="textarea" /></el-form-item>
        <el-form-item label="状态"><el-switch v-model="formData.status" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer
        ><el-button @click="formVisible = false">取消</el-button
        ><el-button type="primary" @click="save">保存</el-button></template
      >
    </el-dialog>
  </div>
</template>
<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import http from "@/api";
import { ElMessage, ElMessageBox } from "element-plus";
const loading = ref(false),
  tableData = ref<any[]>([]),
  page = ref(1),
  total = ref(0);
const formVisible = ref(false),
  formData = reactive<any>({});
const fetchData = async () => {
  loading.value = true;
  try {
    const { data } = await http.get("/service-areas/all", { page: page.value, size: 10 });
    tableData.value = data.records;
    total.value = data.total;
  } finally {
    loading.value = false;
  }
};
const openForm = (row?: any) => {
  Object.assign(formData, row || { id: null, name: "", city: "", district: "", description: "", status: 1 });
  formVisible.value = true;
};
const save = async () => {
  if (formData.id) {
    await http.put("/service-areas/" + formData.id, formData);
  } else {
    await http.post("/service-areas", formData);
  }
  ElMessage.success("保存成功");
  formVisible.value = false;
  fetchData();
};
const del = async (row: any) => {
  await ElMessageBox.confirm("确认删除？");
  await http.delete("/service-areas/" + row.id);
  ElMessage.success("删除成功");
  fetchData();
};
onMounted(fetchData);
</script>
