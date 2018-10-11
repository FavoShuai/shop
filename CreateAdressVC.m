//
//  CreateAdressVC.m
//  Shopping
//
//  Created by apple on 2018/7/13.
//  Copyright © 2018年 啊湫. All rights reserved.
//

#import "CreateAdressVC.h"
#import "ProvinceModel.h"
#import "CityModel.h"
#import "DistrictModel.h"
@interface CreateAdressVC ()<UITextFieldDelegate,NSXMLParserDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *areaTF;
@property (weak, nonatomic) IBOutlet UITextField *detailTF;

/** 选择地区 */
@property (nonatomic,strong) NSXMLParser *parser;
@property (nonatomic,copy) NSString *currentEleName;

@property (nonatomic,strong) UIView *pickerBackView;
@property (nonatomic,strong) UIButton *doneButton;
@property (nonatomic,strong) UIView *btnBackView;
@property (nonatomic,strong) UIPickerView *areaPickerView;
@property (nonatomic,strong) NSMutableArray *provinceArr;
@property (nonatomic,strong) ProvinceModel *proModel;
@property (nonatomic,strong) CityModel *cityModel;
@property (nonatomic,copy) NSString *provinceName;
//@property (nonatomic,copy) NSString *provinceCode;
@property (nonatomic,copy) NSString *cityName;
//@property (nonatomic,copy) NSString *cityCode;
@property (nonatomic,copy) NSString *disName;
//@property (nonatomic,copy) NSString *disCode;
@end

@implementation CreateAdressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == AdressType_Create) {
        self.titleText = @"添加收货地址";
    }else if(self.type == AdressType_Edit){
        self.titleText = @"编辑收货地址";
    }

    if ([Cache objectForKey:DefaultAdress]) {
        [self.provinceArr addObjectsFromArray:(NSArray*)[Cache objectForKey:DefaultAdress]];
    }else{
        // 将耗时操作放到子线程
        dispatch_queue_t queue = dispatch_queue_create("Area", DISPATCH_QUEUE_SERIAL);
        
        dispatch_async(queue, ^{
            [self analysisArea];
            dispatch_async(dispatch_get_main_queue(), ^{
                [Cache setObject:self.provinceArr forKey:DefaultAdress];
            });
        });
    }
}
/** 解析XMl */
- (void)analysisArea{
    NSString* xmlFile = [[NSBundle mainBundle] pathForResource:@"province_data" ofType:@"xml"];
    NSData* xmlData = [[NSData alloc] initWithContentsOfFile:xmlFile];
    self.parser = [[NSXMLParser alloc] initWithData:xmlData];
    self.parser.delegate = self;
    [self.parser parse];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag == 12) {
        [self.view addSubview:self.pickerBackView];
    }
}
- (IBAction)createAdress:(UIButton *)sender {
}
- (IBAction)setDefault:(UIButton *)sender {
    sender.selected = !sender.selected;
}
#pragma mark +-+-+-+-+-+ 地区选择确认
- (void)doneButtonBeClick{
    [self.pickerBackView removeFromSuperview];
    self.pickerBackView = nil;
    self.areaPickerView = nil;
}
#pragma mark +-+-+-+-+-+ NSXMLParserDelegate
-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.currentEleName = elementName;
    if ([self.currentEleName isEqualToString:@"province"]) {
        ProvinceModel* model = [ProvinceModel yy_modelWithDictionary:attributeDict];
        self.proModel = model;
        [self.provinceArr addObject:model];
    }else if ([self.currentEleName isEqualToString:@"city"]){
        
        CityModel* model = [CityModel yy_modelWithDictionary:attributeDict];
        self.cityModel = model;
        [self.proModel setCity:model];
    }else if ([self.currentEleName isEqualToString:@"district"]){
        DistrictModel* model = [DistrictModel yy_modelWithDictionary:attributeDict];
        [self.cityModel setDis:model];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    self.currentEleName = nil;
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}
#pragma mark +-+-+-+-+-+ UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    ProvinceModel* provinceModel = [[ProvinceModel alloc] init];
    CityModel* cityModel = [[CityModel alloc] init];
    if (0 == component) {
        return self.provinceArr.count;
    }
    if (1 == component) {
        NSInteger privoceIndex=[pickerView selectedRowInComponent:0];
        if (self.provinceArr.count > privoceIndex) {
            provinceModel = self.provinceArr[privoceIndex];
            return provinceModel.cityArr.count;
        }
    }
    if (2 == component) {
        NSInteger privoceIndex=[pickerView selectedRowInComponent:0];
        NSInteger cityIndex=[pickerView selectedRowInComponent:1];
        if (self.provinceArr.count > privoceIndex) {
            provinceModel = self.provinceArr[privoceIndex];
            if (provinceModel.cityArr.count > cityIndex) {
                cityModel = provinceModel.cityArr[cityIndex];
                return cityModel.districtArr.count;
            }
        }
        
    }
    return 0;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    ProvinceModel* provincemodel = [[ProvinceModel alloc] init];
    CityModel* cityModel= [[CityModel alloc] init];
    DistrictModel* districtModel = [[DistrictModel alloc] init];
    if (2 == component) {
        NSInteger provinceIndex=[pickerView selectedRowInComponent:0];
        NSInteger cityIndex=[pickerView selectedRowInComponent:1];
        provincemodel = self.provinceArr[provinceIndex];
        if (provincemodel.cityArr.count > cityIndex) {
            cityModel = provincemodel.cityArr[cityIndex];
            if (cityModel.districtArr.count > row) {
                districtModel = cityModel.districtArr[row];
                return districtModel.name;
            }
        }else{
            return  @"";
        }
    }
    if (1 == component) {
        NSInteger provinceIndex=[pickerView selectedRowInComponent:0];
        provincemodel = self.provinceArr[provinceIndex];
        if (provincemodel.cityArr.count > row ) {
            cityModel = provincemodel.cityArr[row];
            return  cityModel.name;
        }else{
            return @"";
        }
    }
    if (0 == component) {
        provincemodel = self.provinceArr[row];
        return provincemodel.name;
    }
    return @"";
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    ProvinceModel* provincemodel = [[ProvinceModel alloc] init];
    if (component == 0) {
        provincemodel = self.provinceArr[row];
        [self selectArea:provincemodel cityIndex:0 districtIndex:0];
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    if (component == 1) {
        NSInteger provinceIndex=[pickerView selectedRowInComponent:0];
        provincemodel = self.provinceArr[provinceIndex];
        if (provincemodel.cityArr.count > row) {
            [self selectArea:provincemodel cityIndex:row districtIndex:0];
        }
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    if (component == 2) {
        NSInteger provinceIndex=[pickerView selectedRowInComponent:0];
        NSInteger cityIndex=[pickerView selectedRowInComponent:1];
        provincemodel = self.provinceArr[provinceIndex];
        if (provincemodel.cityArr.count > cityIndex ) {
            CityModel* model = provincemodel.cityArr[cityIndex];
            if (model.districtArr.count > row) {
                [self selectArea:provincemodel cityIndex:cityIndex districtIndex:row];
            }
        }
    }
}

- (void)selectArea:(ProvinceModel*)model cityIndex:(NSInteger)cityIndex districtIndex:(NSInteger)districtIndex{
    self.provinceName = @"";
    self.cityName = @"";
    self.disName = @"";
//    self.provinceCode = @"";
//    self.cityCode = @"";
//    self.disCode = @"";
    CityModel* cityModel= [[CityModel alloc] init];
    DistrictModel* districtModel = [[DistrictModel alloc] init];
    self.provinceName = model.name;
//    self.provinceCode = model.code;
    if (model.cityArr.count > 0) {
        cityModel = model.cityArr[cityIndex];
        self.cityName = cityModel.name;
//        self.cityCode = cityModel.code;
        if (cityModel.districtArr.count > 0) {
            districtModel = cityModel.districtArr[districtIndex];
            self.disName = districtModel.name;
//            self.disCode = districtModel.code;
        }
    }
    self.areaTF.text = [NSString stringWithFormat:@"%@%@%@",self.provinceName,self.cityName,self.disName];
}
- (UIView*) pickerBackView {
    if (!_pickerBackView) {
        _pickerBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        _pickerBackView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        [_pickerBackView addSubview:self.btnBackView];
        [_pickerBackView addSubview:self.doneButton];
        [_pickerBackView addSubview:self.areaPickerView];
    }
    return _pickerBackView;
}


- (UIButton*) doneButton {
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenW - 80,  kScreenH - kScreenH/3 - 40, 80, 40)];
        [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneButtonBeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}
- (UIView*) btnBackView {
    if (!_btnBackView) {
        _btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH - kScreenH/3 - 40, kScreenW, 40)];
        _btnBackView.userInteractionEnabled = NO;
        _btnBackView.backgroundColor = MainColor;
    }
    return _btnBackView;
}
- (UIPickerView*) areaPickerView {
    if (!_areaPickerView) {
        _areaPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kScreenH*2/3, kScreenW, kScreenH/3)];
        _areaPickerView.delegate = self;
        _areaPickerView.dataSource = self;
        _areaPickerView.backgroundColor = UIColorHex(0xf8f8f8);
    }
    return _areaPickerView;
}
- (NSMutableArray*) provinceArr {
    if (!_provinceArr) {
        _provinceArr=  [[NSMutableArray alloc] init];
    }
    return _provinceArr;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
