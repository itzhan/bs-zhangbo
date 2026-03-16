<template>
  <div class="table-box">
    <el-form :inline="true" :model="search" style="margin-bottom: 16px">
      <el-form-item label="关键词"
        ><el-input v-model="search.keyword" placeholder="用户名/昵称/手机号" clearable style="width: 200px"
      /></el-form-item>
      <el-form-item
        ><el-button type="primary" @click="fetchData">查询</el-button
        ><el-button @click="openForm()">新增用户</el-button></el-form-item
      >
    </el-form>
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="id" label="ID" width="60" />
      <el-table-column prop="username" label="用户名" width="120" />
      <el-table-column prop="nickname" label="昵称" width="120" />
      <el-table-column prop="phone" label="手机号" width="130" />
      <el-table-column prop="role" label="角色" width="90">
        <template #default="{ row }"
          ><el-tag>{{ { USER: "用户", RIDER: "骑手", ADMIN: "管理员" }[row.role] || row.role }}</el-tag></template
        >
      </el-table-column>
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }"
          ><el-tag :type="row.status === 1 ? 'success' : 'danger'">{{ row.status === 1 ? "启用" : "禁用" }}</el-tag></template
        >
      </el-table-column>
      <el-table-column prop="createdAt" label="创建时间" width="170" />
      <el-table-column label="操作" width="280" fixed="right">
        <template #default="{ row }">
          <el-button size="small" @click="openForm(row)">编辑</el-button>
          <el-button size="small" :type="row.status === 1 ? 'danger' : 'success'" @click="toggleStatus(row)">{{
            row.status === 1 ? "禁用" : "启用"
          }}</el-button>
          <el-button size="small" @click="resetPwd(row)">重置密码</el-button>
          <el-button size="small" type="danger" @click="delUser(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination
      v-model:current-page="page"
      :total="total"
      layout="total,prev,pager,next"
      @current-change="fetchData"
      style="margin-top: 16px; justify-content: flex-end"
    />
    <el-dialog v-model="formVisible" :title="formData.id ? '编辑用户' : '新增用户'" width="500px">
      <el-form :model="formData" label-width="80px">
        <el-form-item label="用户名"><el-input v-model="formData.username" :disabled="!!formData.id" /></el-form-item>
        <el-form-item label="昵称"><el-input v-model="formData.nickname" /></el-form-item>
        <el-form-item label="手机号"><el-input v-model="formData.phone" /></el-form-item>
        <el-form-item label="角色">
          <el-select v-model="formData.role">
            <el-option label="用户" value="USER" /><el-option label="骑手" value="RIDER" /><el-option
              label="管理员"
              value="ADMIN"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer
        ><el-button @click="formVisible = false">取消</el-button
        ><el-button type="primary" @click="saveUser">保存</el-button></template
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
  total = ref(0),
  search = ref({ keyword: "" });
const formVisible = ref(false),
  formData = reactive<any>({});
const fetchData = async () => {
  loading.value = true;
  try {
    const { data } = await http.get("/admin/users", {
      page: page.value,
      size: 10,
      role: "USER",
      keyword: search.value.keyword || undefined
    });
    tableData.value = data.records;
    total.value = data.total;
  } finally {
    loading.value = false;
  }
};
const openForm = (row?: any) => {
  Object.assign(formData, row || { id: null, username: "", nickname: "", phone: "", role: "USER" });
  formVisible.value = true;
};
const saveUser = async () => {
  if (formData.id) {
    await http.put("/admin/users/" + formData.id, formData);
  } else {
    await http.post("/admin/users", formData);
  }
  ElMessage.success("保存成功");
  formVisible.value = false;
  fetchData();
};
const toggleStatus = async (row: any) => {
  await http.put("/admin/users/" + row.id + "/status", { status: row.status === 1 ? 0 : 1 });
  ElMessage.success("操作成功");
  fetchData();
};
const resetPwd = async (row: any) => {
  await ElMessageBox.confirm("确认重置密码为123456？");
  await http.put("/admin/users/" + row.id + "/reset-password");
  ElMessage.success("密码已重置");
};
const delUser = async (row: any) => {
  await ElMessageBox.confirm("确认删除？", "警告", { type: "warning" });
  await http.delete("/admin/users/" + row.id);
  ElMessage.success("删除成功");
  fetchData();
};
onMounted(fetchData);
</script>
