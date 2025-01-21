import json
import codecs
import os
import urllib
from urllib.parse import quote
from urllib import request
import sys
import time
import re

class BaiDuPOI(object):
    def __init__(self, itemy, loc):
        self.itemy = itemy  # 这里的 itemy 是关键词“奶茶店”
        self.loc = loc

    def urls(self):
        api_key = amap_api
        urls = []
        for pages in range(1, 100):
            url = "http://restapi.amap.com/v3/place/polygon?key=" + api_key + '&extensions=base&keywords=' + quote(
                    self.itemy) + '&polygon=' + quote(self.loc) + '&offset=20' + '&page=' + str(
                    pages) + '&output=json'
            urls.append(url)
        return urls

    def baidu_search(self):
        json_sel = []
        for url in self.urls():
            print("url", url)
            try:
                with request.urlopen(url) as f:
                    data = f.read().decode('utf-8')
                    data = json.loads(data)
            except Exception as e:
                print(f"请求失败：{e}")
                continue
            print("data", data)
            if data.get('status') != '1':
                break
            if not data.get('pois'):
                break
            for item in data['pois']:
                jid = item.get("id", "")
                jrelated = item.get('parent', '')
                jname = item.get('name', '')
                jtype = item.get('type', '')
                jlocation = item.get("location", '')
                jprov = item.get("pname", '')
                jcity = item.get("cityname", '')
                js_sel = jid + "," + str(jrelated) + ',' + jname + ',' + jtype + ',' + str(
                    jlocation) + ',' + jprov + ',' + jcity
                if jcity == '武汉市':
                    bMap = Bmap(jname, baidu_api)  # 传入百度 API key
                    bMapAddr = bMap.get_addr()
                    js_sel += "," + bMapAddr
                    json_sel.append(js_sel)  # 添加到武汉市的数据列表中
        return json_sel

class LocaDiv(object):
    def __init__(self, loc_all):
        self.loc_all = loc_all

    def lat_all(self):
        lat_nw = float(self.loc_all.split(',')[1])
        lat_se = float(self.loc_all.split(',')[3])
        print("纬度分块大小及多少", int((lat_nw - lat_se + 0.0001) / 0.1))
        lat_list = []
        for i in range(0, int((lat_nw - lat_se + 0.0001) / 0.1)):
            lat_list.append(round(lat_se + 0.1 * i, 6))
        lat_list.append(lat_nw)
        return lat_list

    def lng_all(self):
        lng_nw = float(self.loc_all.split(',')[0])
        lng_se = float(self.loc_all.split(',')[2])
        print("经度分块大小及多少", int((lng_se - lng_nw + 0.0001) / 0.1))
        lng_list = []
        for i in range(0, int((lng_se - lng_nw + 0.0001) / 0.1)):
            lng_list.append(round(lng_nw + 0.1 * i, 6))
        lng_list.append(lng_se)
        return lng_list

    def ls_com(self):
        l1 = self.lat_all()
        l2 = self.lng_all()
        print("lng_all", l2)
        print("lat_all", l1)
        ab_list = []
        for i in range(len(l1)):
            a = str(l1[i])
            for j in range(len(l2)):
                b = str(l2[j])
                ab = b + ',' + a
                ab_list.append(ab)
        return ab_list

    def ls_row(self):
        l1 = self.lat_all()
        l2 = self.lng_all()
        ls_com_v = self.ls_com()
        ls = []
        for n in range(len(l1) - 1):
            for i in range(len(l2) * n, len(l2) * (n + 1) - 1):
                a = ls_com_v[i]
                b = ls_com_v[i + len(l2) + 1]
                ab = a + ',' + b
                ls.append(ab)
        return ls

class Bmap(object):
    def __init__(self, wd, ak):
        self.wd = wd
        self.url = "https://api.map.baidu.com/?qt=s&c=218&wd=" + quote(wd) + "" \
                   "&rn=10&ie=utf-8&oue=1&fromproduct=jsapi&res=api&callback=BMap._rd._cbk9406" \
                   "&ak=" + quote(ak)

    def get_addr(self):
        addr = ""
        uid = ""
        poiboundary = ""
        try:
            with request.urlopen(self.url) as f:
                data = f.read().decode('utf-8')
                result = self.loads_jsonp(data)
        except Exception as e:
            print(f"百度地图请求失败：{e}")
            return addr + "," + uid + "," + poiboundary
        print("result is", result, "url is", self.url)
        content = result.get("content")
        if content and len(content) > 0:
            first_item = content[0]
            if first_item.get("acc_flag") is not None:
                addr = first_item.get('address_norm', '')
                uid = first_item.get('uid', '')
                ext = first_item.get("ext", {})
                detail_info = ext.get("detail_info", {})
                guoke_geo = detail_info.get("guoke_geo", {})
                poiboundary = guoke_geo.get("geo", "")
        return addr + "," + uid + "," + poiboundary

    def loads_jsonp(self, _jsonp):
        """
        解析 JSONP 数据格式为 JSON。
        """
        try:
            return json.loads(re.match(".*?({.*}).*", _jsonp, re.S).group(1))
        except Exception as e:
            print(f"解析 JSONP 失败：{e}")
            raise ValueError('Invalid Input')

if __name__ == '__main__':
    # API Key
    baidu_api = "C2BpSFyhwLRYSYuYgWarlaXU9UhYR4tu"
    amap_api = "08e2d028f9920fce092daa3bf4bc30a8"

    print("开始爬取数据，请稍等...")
    start_time = time.time()

    # 武汉市坐标：左上角 (lng, lat)，右下角 (lng, lat)
    loc = LocaDiv('113.41,31.38,115.05,29.98')

    # 获取要使用的网格区域列表
    locs_to_use = loc.ls_row()
    print("locs_to_use", locs_to_use)

    # 打开 CSV 文件进行写入
    with open('wuhan_milk_tea_shops.csv', 'w+', encoding='utf-8') as doc:
        for loc_to_use in locs_to_use:
            par = BaiDuPOI('奶茶店', loc_to_use)  # 使用关键词“奶茶店”
            data_list = par.baidu_search()
            for data_line in data_list:
                doc.write(data_line)
                doc.write('\n')

    end_time = time.time()
    print("奶茶店 POI 数据爬取完毕，用时 %.2f 秒" % (end_time - start_time))
