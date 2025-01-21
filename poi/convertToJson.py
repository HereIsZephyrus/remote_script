import json
import pandas as pd

def filtered(POIid):
    bigCategory = POIid[0:2]
    middleCategory = POIid[0:4]
    if (bigCategory in ['99', '98', '97', '22', '20', '19', '18', '02', '03', '04']):
        return True
    if (middleCategory in ['0908', '1304', '1602', '1603', '1804', '1805']):
        return True
    return False

def main():
    rawData = []
    filteredData = []
    with open('wuhanpoi.txt', 'r', encoding='utf-8') as file:
        for line in file:
            record = line.strip().split(',')
            categories = record[1].split('|')[0].split(';')
            if (len(categories) < 3):
                continue
            #print(record)
            #print(categories)
            #wgscoord = gcj02_to_wgs84(float(record[3]), float(record[4]))
            POIid = record[13]
            rawData.append({
                '名称': record[0],
                '大类名称': categories[0],
                '中类名称': categories[1],
                '小类名称': categories[2],
                '联系电话': record[2],
                '经度': record[17],
                '纬度': record[18],
                '海拔': record[5],
                '地址': record[6],
                '省名': record[7],
                '市名': record[8],
                '省内编号' : record[9],
                '区名' : record[10],
                '路名' : record[11],
                '邮政编码' : record[12],
                'POI-ID' : POIid,
                '门牌号' : record[16],
            })
            if (filtered(POIid)):
                continue
            filteredData.append({
                'POI-ID': POIid,
                '名称': record[0],
                '大类名称': categories[0],
                '中类名称': categories[1],
                '小类名称': categories[2],
                '经度': record[17],
                '纬度': record[18],
                '地址': record[6],
                '市名': record[8],
                '邮政编码': record[12],
            })

    json_data = json.dumps(rawData, ensure_ascii=False, indent=4)
    with open('rawwuhanpoi.json', 'w', encoding='utf-8') as file:
        file.write(json_data)
    df = pd.DataFrame(filteredData)
    df.to_csv('filteredwuhanpoi.csv', index=False,encoding='utf-8-sig')


if __name__ == '__main__':
    main()