# 2025-08-17T00:40:26.717304600
import vitis

client = vitis.create_client()
client.set_workspace(path="fusion_top")

vitis.dispose()

