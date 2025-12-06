# CODE DUPLICATION FIX - REFACTORING GUIDE

## 🎯 Problem
SonarCloud detected **97.68% code duplication** across the frontend codebase, primarily in React components with repeated patterns:
- `useState` declarations (loading, error, message states)
- API call patterns with loading/error handling
- Modal management
- Form state management
- Similar UI components (tables, alerts, spinners)

## ✅ Solution: Custom Hooks & Shared Components

### 📦 Custom Hooks Created (`frontend/src/hooks/`)

#### 1. **useApiState.js** - API State Management
Replaces repeated state declarations:
```javascript
// ❌ Before (repeated in 17+ files):
const [loading, setLoading] = useState(true);
const [error, setError] = useState(null);
const [message, setMessage] = useState('');
const [messageType, setMessageType] = useState('');

// ✅ After:
import { useApiState } from '../hooks';
const { loading, error, message, messageType, setSuccessMessage, setErrorMessage } = useApiState();
```

#### 2. **useApiCall.js** - API Call Handler
Standardizes API calls with automatic loading/error handling:
```javascript
// ✅ Usage:
import { useApiCall } from '../hooks';
const { loading, error, data, execute } = useApiCall(apiFunction);
await execute(params);
```

#### 3. **useBatchApiCall.js** - Batch API Calls
For Promise.all patterns:
```javascript
// ✅ Usage:
import { useBatchApiCall } from '../hooks';
const { loading, error, executeBatch } = useBatchApiCall();
const results = await executeBatch([api1(), api2(), api3()]);
```

#### 4. **useFormState.js** - Form State Management
Replaces repeated form handling:
```javascript
// ✅ Usage:
import { useFormState } from '../hooks';
const { formData, handleInputChange, resetForm } = useFormState(initialData);
```

#### 5. **useModal.js** - Modal State Management
Standardizes modal open/close logic:
```javascript
// ✅ Usage:
import { useModal } from '../hooks';
const { isOpen, modalData, openModal, closeModal } = useModal();
```

### 🎨 Shared UI Components (`frontend/src/components/common/`)

#### 1. **LoadingSpinner.js** - Loading State
```javascript
import { LoadingSpinner } from '../../components/common';
<LoadingSpinner size="md" text="Loading data..." />
```

#### 2. **ErrorDisplay.js** - Error State
```javascript
import { ErrorDisplay } from '../../components/common';
<ErrorDisplay error={error} onRetry={fetchData} />
```

#### 3. **MessageAlert.js** - Success/Error Messages
```javascript
import { MessageAlert } from '../../components/common';
<MessageAlert message={message} messageType={messageType} onClose={clearMessage} />
```

#### 4. **Modal.js** - Reusable Modal
```javascript
import { Modal } from '../../components/common';
<Modal isOpen={isOpen} onClose={close} title="Edit Data" size="lg">
  {/* content */}
</Modal>
```

#### 5. **ConfirmModal.js** - Confirmation Dialog
```javascript
import { ConfirmModal } from '../../components/common';
<ConfirmModal 
  isOpen={isOpen} 
  onConfirm={handleDelete}
  message="Are you sure?"
/>
```

#### 6. **DataTable.js** - Reusable Table
```javascript
import { DataTable } from '../../components/common';
<DataTable 
  data={items} 
  columns={columns}
  actions={[{ label: 'Edit', onClick: handleEdit }]}
/>
```

#### 7. **FormInput.js** - Form Fields
```javascript
import { FormInput } from '../../components/common';
<FormInput 
  label="Name" 
  name="nama" 
  value={formData.nama}
  onChange={handleInputChange}
  required
/>
```

#### 8. **SearchBar.js** - Search Input
```javascript
import { SearchBar } from '../../components/common';
<SearchBar 
  value={searchTerm} 
  onChange={setSearchTerm}
  placeholder="Search students..."
/>
```

### 📊 Analytics Components (`frontend/src/components/analytics/`)

#### 1. **AnalyticsBarChart.js** - Bar Charts
```javascript
import { AnalyticsBarChart } from '../../components/analytics';
<AnalyticsBarChart 
  data={chartData}
  bars={[{ key: 'rata_rata', name: 'Average', color: '#82ca9d' }]}
/>
```

#### 2. **AnalyticsTabs.js** - Tab Navigation
```javascript
import { AnalyticsTabs } from '../../components/analytics';
<AnalyticsTabs 
  tabs={[{ id: 'school', label: 'School' }]}
  activeTab={activeTab}
  onTabChange={setActiveTab}
/>
```

#### 3. **AnalyticsFilterSection.js** - Filters
```javascript
import { AnalyticsFilterSection } from '../../components/analytics';
<AnalyticsFilterSection 
  filters={filterConfig}
  onFilterChange={handleFilterChange}
/>
```

#### 4. **AnalyticsDataTable.js** - Data Tables
```javascript
import { AnalyticsDataTable } from '../../components/analytics';
<AnalyticsDataTable 
  data={tableData}
  columns={columns}
/>
```

## 🔧 Refactoring Priority (High to Low Duplication)

### Phase 1: Highest Duplication Files
1. ✅ **teacherClassEnroll.js** (22 useState declarations)
2. ✅ **teacher.js** (16 useState)
3. ✅ **analytics.js** (admin & guru - 13 useState each)

### Phase 2: Medium Duplication Files
4. ✅ **WaliKelasGradeView.js** (12 useState)
5. ✅ **student.js** (11 useState)
6. ✅ **classManagement.js**
7. ✅ **gradeManagement.js**

### Phase 3: Remaining Files
8. ✅ All other feature files in `admin/` and `guru/`

## 📝 Migration Example

### Before (Duplicated Code):
```javascript
// Repeated in EVERY file:
const [loading, setLoading] = useState(true);
const [error, setError] = useState(null);
const [message, setMessage] = useState('');
const [messageType, setMessageType] = useState('');
const [isModalOpen, setIsModalOpen] = useState(false);

const fetchData = async () => {
  setLoading(true);
  setError(null);
  try {
    const data = await api.getData();
    setData(data);
  } catch (err) {
    setError(err.message);
  } finally {
    setLoading(false);
  }
};

const handleDelete = async (id) => {
  try {
    await api.delete(id);
    setMessage('Deleted successfully');
    setMessageType('success');
    setTimeout(() => {
      setMessage('');
      setMessageType('');
    }, 3000);
  } catch (err) {
    setMessage(err.message);
    setMessageType('error');
  }
};
```

### After (Using Hooks & Components):
```javascript
import { useApiState, useModal } from '../hooks';
import { LoadingSpinner, ErrorDisplay, MessageAlert } from '../components/common';

const { loading, error, message, messageType, setSuccessMessage, setErrorMessage } = useApiState();
const { isOpen, openModal, closeModal } = useModal();

const fetchData = async () => {
  setLoading(true);
  try {
    const data = await api.getData();
    setData(data);
  } catch (err) {
    setError(err.message);
  } finally {
    setLoading(false);
  }
};

const handleDelete = async (id) => {
  try {
    await api.delete(id);
    setSuccessMessage('Deleted successfully');
  } catch (err) {
    setErrorMessage(err.message);
  }
};

// In JSX:
{loading && <LoadingSpinner />}
{error && <ErrorDisplay error={error} />}
<MessageAlert message={message} messageType={messageType} />
```

## 📊 Expected Results

### Before:
- **97.68% Code Duplication** ❌
- Reliability Rating: D ❌
- Maintainability Rating: B ❌

### After:
- **< 3% Code Duplication** ✅
- Reliability Rating: A ✅ (by fixing identified bugs)
- Maintainability Rating: A ✅ (cleaner, DRY code)

## 🚀 Next Steps

1. ✅ Create custom hooks (DONE)
2. ✅ Create shared UI components (DONE)
3. ✅ Create analytics components (DONE)
4. 🔄 Refactor high-duplication files (IN PROGRESS)
5. ⏳ Test functionality after refactoring
6. ⏳ Run SonarCloud scan again
7. ⏳ Fix any remaining bugs/code smells
8. ⏳ Verify Quality Gate PASSES

## 💡 Best Practices Going Forward

1. **Always use custom hooks** for state management
2. **Reuse shared components** instead of creating new ones
3. **Extract common logic** into utilities/hooks
4. **Keep components focused** on single responsibility
5. **Use barrel exports** (`index.js`) for cleaner imports

## 📚 Import Patterns

```javascript
// Custom Hooks
import { useApiState, useModal, useFormState } from '../hooks';

// Common Components
import { 
  LoadingSpinner, 
  ErrorDisplay, 
  MessageAlert,
  DataTable,
  Modal,
  FormInput
} from '../components/common';

// Analytics Components
import { 
  AnalyticsBarChart, 
  AnalyticsTabs 
} from '../components/analytics';
```

---

**Status**: 🟡 Hooks & Components Created - Ready for File Refactoring
**Last Updated**: 2024
**SonarCloud Target**: < 3% duplication, Reliability A, Maintainability A
