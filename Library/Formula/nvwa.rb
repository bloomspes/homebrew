require 'formula'

class Nvwa <Formula
  url 'http://sourceforge.net/projects/nvwa/files/nvwa/0.8.2/nvwa-0.8.2.tar.gz'
  homepage 'http://nvwa.sourceforge.net/'
  md5 '9fa35cca2793c7d969cd49815dc4bdc0'

  def patches
    # fixes use of reserved variable __blocks and size_t printfs
    DATA
  end

  def install
    ENV.fast
    Dir.chdir "nvwa" do
      system "#{ENV.cxx} #{ENV.cflags} -c *.cpp"
      system "libtool -static -o libnvwa.a *.o"
    end
    (include + name).install Dir['nvwa/*.h']
    lib.install "nvwa/libnvwa.a"
  end
end

__END__
diff --git a/nvwa/debug_new.cpp b/nvwa/debug_new.cpp
index 48569dd..e8ca381 100644
--- a/nvwa/debug_new.cpp
+++ b/nvwa/debug_new.cpp
@@ -499,9 +499,9 @@ static void* alloc_mem(size_t size, const char* file, int line, bool is_array)
     {
         fast_mutex_autolock lock(new_output_lock);
         fprintf(new_output_fp,
-                "new%s: allocated %p (size %u, ",
+                "new%s: allocated %p (size %lu, ",
                 is_array ? "[]" : "",
-                pointer, size);
+                pointer, (unsigned long)size);
         if (line != 0)
             print_position(ptr->file, ptr->line);
         else
@@ -548,10 +548,10 @@ static void free_pointer(void* pointer, void* addr, bool is_array)
             msg = "delete after new[]";
         fast_mutex_autolock lock(new_output_lock);
         fprintf(new_output_fp,
-                "%s: pointer %p (size %u)\n\tat ",
+                "%s: pointer %p (size %lu)\n\tat ",
                 msg,
                 (char*)ptr + ALIGNED_LIST_ITEM_SIZE,
-                ptr->size);
+                (unsigned long)ptr->size);
         print_position(addr, 0);
         fprintf(new_output_fp, "\n\toriginally allocated at ");
         if (ptr->line != 0)
@@ -581,10 +581,10 @@ static void free_pointer(void* pointer, void* addr, bool is_array)
     {
         fast_mutex_autolock lock(new_output_lock);
         fprintf(new_output_fp,
-                "delete%s: freed %p (size %u, %u bytes still allocated)\n",
+                "delete%s: freed %p (size %lu, %lu bytes still allocated)\n",
                 is_array ? "[]" : "",
                 (char*)ptr + ALIGNED_LIST_ITEM_SIZE,
-                ptr->size, total_mem_alloc);
+                (unsigned long)ptr->size, (unsigned long)total_mem_alloc);
     }
     free(ptr);
     return;
@@ -619,9 +619,9 @@ int check_leaks()
         }
 #endif
         fprintf(new_output_fp,
-                "Leaked object at %p (size %u, ",
+                "Leaked object at %p (size %lu, ",
                 pointer,
-                ptr->size);
+                (unsigned long)ptr->size);
         if (ptr->line != 0)
             print_position(ptr->file, ptr->line);
         else
@@ -663,9 +663,9 @@ int check_mem_corruption()
         {
 #endif
             fprintf(new_output_fp,
-                    "Heap data corrupt near %p (size %u, ",
+                    "Heap data corrupt near %p (size %lu, ",
                     pointer,
-                    ptr->size);
+                    (unsigned long)ptr->size);
 #if _DEBUG_NEW_TAILCHECK
         }
         else
diff --git a/nvwa/static_mem_pool.h b/nvwa/static_mem_pool.h
index 7c68eb4..d0552a3 100644
--- a/nvwa/static_mem_pool.h
+++ b/nvwa/static_mem_pool.h
@@ -173,9 +173,9 @@ public:
     {
         assert(__ptr != NULL);
         lock __guard;
-        _Block_list* __block = reinterpret_cast<_Block_list*>(__ptr);
-        __block->_M_next = _S_memory_block_p;
-        _S_memory_block_p = __block;
+        _Block_list* _block = reinterpret_cast<_Block_list*>(__ptr);
+        _block->_M_next = _S_memory_block_p;
+        _S_memory_block_p = _block;
     }
     virtual void recycle();
 
@@ -190,12 +190,12 @@ private:
 #   ifdef _DEBUG
         // Empty the pool to avoid false memory leakage alarms.  This is
         // generally not necessary for release binaries.
-        _Block_list* __block = _S_memory_block_p;
-        while (__block)
+        _Block_list* _block = _S_memory_block_p;
+        while (_block)
         {
-            _Block_list* __next = __block->_M_next;
-            dealloc_sys(__block);
-            __block = __next;
+            _Block_list* __next = _block->_M_next;
+            dealloc_sys(_block);
+            _block = __next;
         }
         _S_memory_block_p = NULL;
 #   endif
@@ -239,15 +239,15 @@ void static_mem_pool<_Sz, _Gid>::recycle()
     // before the pool-specific lock.  However, no race conditions are
     // found so far.
     lock __guard;
-    _Block_list* __block = _S_memory_block_p;
-    while (__block)
+    _Block_list* _block = _S_memory_block_p;
+    while (_block)
     {
-        if (_Block_list* __temp = __block->_M_next)
+        if (_Block_list* __temp = _block->_M_next)
         {
             _Block_list* __next = __temp->_M_next;
-            __block->_M_next = __next;
+            _block->_M_next = __next;
             dealloc_sys(__temp);
-            __block = __next;
+            _block = __next;
         }
         else
         {
