#import "CAICloudPhoneCell.h"
#import "CAIDemoIcon.h"
#import "CAIDemoAccessibilityIds.h"

@implementation CAICloudPhoneCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 截图预览区，按 9:16 比例展示
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor lightGrayColor];

        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:10];
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = [UIColor darkTextColor];

        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;

        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_textLabel];
        [self.contentView addSubview:_activityIndicator];

        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;

        _masterButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_masterButton setTitle:@"设为主控" forState:UIControlStateNormal];
        [_masterButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_masterButton setTitle:@"主控中" forState:UIControlStateSelected];
        [_masterButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        _masterButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _masterButton.layer.borderWidth = 1;
        _masterButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _masterButton.layer.cornerRadius = 4;
        _masterButton.accessibilityIdentifier = CAIIdControlCellMaster;
        [_masterButton addTarget:self action:@selector(masterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        _slaveCheckbox = [UIButton buttonWithType:UIButtonTypeCustom];
        [_slaveCheckbox setImage:[CAIDemoIcon imageWithSystemName:@"square" fallbackAssetName:@"login_radio_unselected"]
                        forState:UIControlStateNormal];
        [_slaveCheckbox setImage:[CAIDemoIcon imageWithSystemName:@"checkmark.square.fill" fallbackAssetName:@"login_radio_selected"]
                        forState:UIControlStateSelected];
        [_slaveCheckbox setTitle:@" 被控" forState:UIControlStateNormal];
        [_slaveCheckbox setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _slaveCheckbox.titleLabel.font = [UIFont systemFontOfSize:12];
        _slaveCheckbox.accessibilityIdentifier = CAIIdControlCellSlave;
        [_slaveCheckbox addTarget:self action:@selector(slaveCheckboxTapped:) forControlEvents:UIControlEventTouchUpInside];

        UIStackView *controlStack = [[UIStackView alloc] initWithArrangedSubviews:@[_masterButton, _slaveCheckbox]];
        controlStack.axis = UILayoutConstraintAxisHorizontal;
        controlStack.distribution = UIStackViewDistributionFillEqually;
        controlStack.spacing = 8;
        controlStack.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:controlStack];

        [NSLayoutConstraint activateConstraints:@[
            [_imageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
            [_imageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8],
            [_imageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8],
            [_imageView.heightAnchor constraintEqualToAnchor:_imageView.widthAnchor multiplier:16.0/9.0],

            [_textLabel.topAnchor constraintEqualToAnchor:_imageView.bottomAnchor constant:8],
            [_textLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8],
            [_textLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8],

            [controlStack.topAnchor constraintEqualToAnchor:_textLabel.bottomAnchor constant:8],
            [controlStack.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8],
            [controlStack.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8],
            [controlStack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
            [controlStack.heightAnchor constraintEqualToConstant:30],

            [_activityIndicator.centerXAnchor constraintEqualToAnchor:_imageView.centerXAnchor],
            [_activityIndicator.centerYAnchor constraintEqualToAnchor:_imageView.centerYAnchor],
        ]];
    }
    return self;
}

- (void)masterButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cellDidSelectMasterForInstanceId:)]) {
        [self.delegate cellDidSelectMasterForInstanceId:_instanceId];
    }
}

- (void)slaveCheckboxTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(cell:didChangeSlaveState:forInstanceId:)]) {
        [self.delegate cell:self didChangeSlaveState:sender.selected forInstanceId:_instanceId];
    }
}

@end
